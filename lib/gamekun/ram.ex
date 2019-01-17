defmodule GameKun.RAM do
  use GenServer
  alias __MODULE__, as: RAM_S
  require Bitwise

  defstruct wram: %{}, hram: %{}

  # API
  def start_link(_args) do
    GenServer.start_link(__MODULE__, %RAM_S{}, name: RAM)
  end

  def read(pos) do
    GenServer.call(RAM, {:read, pos})
  end

  def write(pos, value) do
    GenServer.cast(RAM, {:write, pos, value})
  end

  # Server
  def init(init_state) do
    # 8 Banks of 4k starting from 0xc000
    wram = gen_range_map(0xC000..0x016000)
    hram = init_hram()

    updated_state = %RAM_S{
      init_state
      | wram: wram,
        hram: hram
    }

    {:ok, updated_state}
  end

  defp gen_range_map(range) do
    range
    |> Stream.zip(Stream.cycle([<<0x00>>]))
    |> Enum.into(%{})
  end

  defp init_hram() do
    range = gen_range_map(0xFF00..0xFFFF)
    init = Application.fetch_env!(:gamekun, :init)
    Map.merge(range, init)
  end

  def handle_call({:read, pos}, _from, memory) do
    value =
      cond do
        pos in 0xC000..0xCFFF ->
          memory.wram[pos]

        pos in 0xD000..0xDFFF ->
          actual = get_bank(memory) * 0x1000 + pos
          memory.wram[actual]

        pos in 0xFF00..0xFFFF ->
          memory.hram[pos]
      end

    {:reply, value, memory}
  end

  def handle_cast({:write, pos, value}, memory) do
    updated =
      cond do
        pos in 0xC000..0xCFFF ->
          %{memory | :wram => %{memory.wram | pos => value}}

        pos in 0xD000..0xDFFF ->
          actual = get_bank(memory) * 0x1000 + pos
          %{memory | :wram => %{memory.wram | actual => value}}

        pos == 0xFF70 ->
          adjusted =
          case value do
            <<0>> ->
              <<0x01>>
            <<n>> ->
              <<n>>
          end
          %{memory | :hram => %{memory.hram | pos => adjusted}}
        pos in 0xFF00..0xFFFF ->
          %{memory | :hram => %{memory.hram | pos => value}}
      end

    {:noreply, updated}
  end

  defp get_bank(memory) do
    memory.hram[0xFF70]
    |> :binary.decode_unsigned()
    |> Bitwise.band(7)
  end
end
