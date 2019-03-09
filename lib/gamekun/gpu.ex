defmodule GameKun.GPU do
  use GenServer
  use Bitwise
  alias __MODULE__, as: GPU_S
  alias GameKun.MMU, as: MMU
  defstruct vram: %{}, mode: 0, clock: 0, line: 0

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: GPU)
  end

  def read(pos) do
    GenServer.call(GPU, {:read, pos})
  end

  def write(pos, value) do
    GenServer.cast(GPU, {:write, pos, value})
  end

  def step(amt) do
    GenServer.cast(GPU, {:step, amt})
  end

  # Server
  def init(_args) do
    vram =
      0x8000..0xBFFF
      |> Stream.zip(Stream.cycle([<<0x00>>]))
      |> Enum.into(%{})
    state = %GPU_S{vram: vram}
    {:ok, state}
  end

  def handle_call({:read, pos}, _from, state) do
    actual = actual_position(pos)
    value = state.vram[actual]
    {:reply, value, state}
  end

  def handle_cast({:step, amt}, state) do
    state = gpu_step(%{state | clock: state.clock + amt})
    {:noreply, state}
  end

  def handle_cast({:write, pos, value}, state) do
    actual = actual_position(pos)
    state = put_in(state.vram[actual], value)
    {:noreply, state}
  end

  defp actual_position(pos) do
    GameKun.RAM.read(0xFF4F)
    |> :binary.decode_unsigned()
    |> Bitwise.band(1)
    |> Kernel.*(0x2000)
    |> Kernel.+(pos)
  end

  def gpu_step(%{mode: 0, clock: clock} = state) when clock >= 204 do
    clock = 0
    line = state.line + 1
    MMU.write(0xFF44, <<line>>)
    state = %{state | clock: clock, line: line}
    if line == 143, do: %{state | mode: 1}, else: %{state | mode: 2}
  end

  def gpu_step(%{mode: 1, clock: clock} = state) when clock >= 456 do
    clock = 0
    line = state.line + 1
    MMU.write(0xFF44, <<line>>)
    state = %{state | clock: clock, line: line}
    if line > 153, do: %{state | mode: 2, line: 0}, else: state
  end

  def gpu_step(%{mode: 2, clock: clock} = state) when clock >= 80 do
    %{state | mode: 3, clock: 0}
  end

  def gpu_step(%{mode: 3, clock: clock} = state) when clock >= 172 do
    %{state | mode: 0, clock: 0}
  end

  def gpu_step(state) do
    state
  end
end
