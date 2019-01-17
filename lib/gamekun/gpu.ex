defmodule GameKun.GPU do
  use GenServer

  require Bitwise
  defstruct vram: %{}, bank: 0

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: GPU)
  end

  def read(pos) do
    GenServer.call(GPU, {:read, pos})
  end

  def write(pos, value) do
    GenServer.cast(GPU, {:write, pos, value})
  end

  # Server
  def init(_args) do
    vram =
      0x8000..0xBFFF
      |> Stream.zip(Stream.cycle([<<0x00>>]))
      |> Enum.into(%{})

    {:ok, vram}
  end

  def handle_call({:read, pos}, _from, vram) do
    actual = actual_position(pos)
    value = vram[actual]
    {:reply, value, vram}
  end

  def handle_cast({:write, pos, value}, vram) do
    actual = actual_position(pos)
    updated = %{vram | actual => value}
    {:noreply, updated}
  end

  defp actual_position(pos) do
    GameKun.RAM.read(0xFF4F)
    |> :binary.decode_unsigned()
    |> Bitwise.band(1)
    |> Kernel.*(0x2000)
    |> Kernel.+(pos)
  end
end
