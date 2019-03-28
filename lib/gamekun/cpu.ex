defmodule GameKun.CPU do
  use GenServer
  use Bitwise
  alias GameKun.MMU, as: MMU

  # API
  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: CPU)
  end

  # Server
  def init(_args) do
    Process.send_after(self(), :process, 0)

    cpu_state =
      GameKun.MMU.read(0x0143)
      |> get_initial_state()

    {:ok, cpu_state}
  end

  def get_initial_state(gb_type) when gb_type in [<<0x00>>, <<0x80>>] do
    Application.fetch_env!(:gamekun, :gb_reg)
  end

  def get_initial_state(_), do: raise("Not Supported")

  def handle_info(:process, state) do
    process(state)
    {:noreply, state}
  end

  def process(cpu_state) do
    state = halt(cpu_state.halt, cpu_state)

    state =
      requested_interrupts()
      |> handle_interrupts(state)

    state =
      state.pc
      |> GameKun.MMU.read()
      |> GameKun.Ops.decode(state)

    (state.cycles - cpu_state.cycles)
    |> step_peripherals()

    process(state)
  end

  def halt(-1, state) do
    step_peripherals(4)

    requested_interrupts()
    |> halt(state)
  end

  def halt(_, state), do: %{state | halt: 0}

  def step_peripherals(amt) do
    GameKun.GPU.step(amt)
  end

  def requested_interrupts() do
    <<interrupt_flag>> = GameKun.MMU.read(0xFF0F)
    <<enabled_interrupts>> = GameKun.MMU.read(0xFFFF)
    interrupt_flag &&& enabled_interrupts
  end

  def handle_interrupts(requested, %{ime: 1} = state) when requested != 0 do
    sp = GameKun.Ops.Impl.push(state.pc, state)
    pc = vector(<<requested>>)
    %{state | pc: pc, sp: sp, cycles: state.cycles + 20, ime: 0}
  end

  def handle_interrupts(_requested, state) do
    state
  end

  # V-Blank
  def vector(<<msb::7, 1::1, _::0>>) do
    MMU.write(0xFFFF, <<msb <<< 1>>)
    0x40
  end

  # LCD STAT
  def vector(<<msb::6, 1::1, _::1>>) do
    MMU.write(0xFFFF, <<msb <<< 2>>)
    0x48
  end

  # Timer
  def vector(<<msb::5, 1::1, _::2>>) do
    MMU.write(0xFFFF, <<msb <<< 3>>)
    0x50
  end

  # Serial
  def vector(<<msb::4, 1::1, _::3>>) do
    MMU.write(0xFFFF, <<msb <<< 4>>)
    0x58
  end

  # Joypad
  def vector(<<msb::3, 1::1, _::4>>) do
    MMU.write(0xFFFF, <<msb <<< 5>>)
    0x60
  end
end
