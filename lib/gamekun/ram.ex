defmodule GameKun.RAM do
  use GenServer
  alias __MODULE__, as: RAM_S
  require Bitwise

  defstruct wram: %{}, hram: %{}

  # API
  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: RAM)
  end

  def read(pos, len \\ 1) do
    GenServer.call(RAM, {:read, pos, len})
  end

  def write(pos, value) do
    GenServer.cast(RAM, {:write, pos, value})
  end

  # Server
  def init(_init_state) do
    # 8 Banks of 4k starting from 0xc000
    wram = gen_range_map(0xC000..0x016000)
    hram = init_hram()

    state = %RAM_S{
      wram: wram,
      hram: hram
    }

    {:ok, state}
  end

  defp gen_range_map(range) do
    range
    |> Stream.zip(Stream.cycle([<<0x00>>]))
    |> Enum.into(%{})
  end

  defp init_hram() do
    range = gen_range_map(0xFF00..0xFFFF)
    init = Application.fetch_env!(:gamekun, :hram)
    Map.merge(range, init)
  end

  def handle_call({:read, pos, len}, _from, memory) do
    value =
      cond do
        pos in 0xC000..0xCFFF ->
          read(memory.wram, pos, len)

        pos in 0xD000..0xDFFF ->
          actual = get_bank(memory) * 0x1000 + pos
          read(memory.wram, actual, len)

        pos in 0xFF00..0xFFFF ->
          read(memory.hram, pos, len)
      end

    {:reply, value, memory}
  end

  def read(ram, pos, 1) do
    ram[pos]
  end

  def read(ram, pos, len) do
    Map.take(ram, pos..(pos+len-1))
      |> Enum.to_list()
      |> Enum.into(<<>>, fn {_, val} -> val end)
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

              n ->
                n
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
