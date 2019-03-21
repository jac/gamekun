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
    Process.send_after(self(), :begin, 0)

    cpu_state =
      case GameKun.MMU.read(0x0143) do
        <<0>> ->
          Application.fetch_env!(:gamekun, :gb_reg)

        x when x in [<<0x80>>, <<0xC0>>] ->
          Application.fetch_env!(:gamekun, :cgb_reg)
          raise "Not Implemented"
      end

    {:ok, cpu_state}
  end

  def handle_info(:begin, state) do
    GenServer.cast(self(), :process)
    {:noreply, state}
  end

  def handle_info(:interrupt, state = %{ime: 1, ime_cycle_accuracy: true}) do
    state = handle_interrupt(state)
    {:noreply, state}
  end

  def handle_info(:interrupt, state) do
    GenServer.cast(self(), :process)
    {:noreply, state}
  end

  def handle_info(:halt, state) do
    %{state | cycles: state.cycles + 4}
  end

  def handle_cast(:process, cpu_state) do
    # Interrupts are not serviced the same cycle IE is called
    cpu_state = %{
      cpu_state
      | ime_cycle_accuracy: cpu_state.ime_cycle_accuracy == (cpu_state.ime == 1)
    }

    state =
      cpu_state.pc
      |> GameKun.MMU.read()
      |> GameKun.Ops.decode(cpu_state)

    cycle_diff = state.cycles - cpu_state.cycles
    GameKun.GPU.step(cycle_diff)
    {_, mailbox_length} = Process.info(self(), :message_queue_len)
    if mailbox_length == 0, do: GenServer.cast(self(), :process)
    {:noreply, state}
  end

  def handle_interrupt(state) do
    <<interrupt_flag>> = GameKun.MMU.read(0xFF0F)
    <<interrupts_enabled>> = GameKun.MMU.read(0xFFFF)
    requested = interrupt_flag &&& interrupts_enabled
    sp = GameKun.Ops.Impl.push(state.pc, state)
    pc = interrupt(<<requested>>)
    GenServer.cast(self(), :process)

    # Allow for the possibility of more than one interrupt to have been triggered in the same cycle
    # If no interrupts to process it will be ignored
    GenServer.cast(self(), :interrupt)
    %{state | pc: pc, sp: sp, cycles: state.cycles + 20, ime: 0, ime_cycle_accuracy: false}
  end

  # V-Blank
  def interrupt(<<msb::7, 1::1, _::0>>) do
    MMU.write(0xFFFF, <<msb <<< 1>>)
    0x40
  end

  # LCD STAT
  def interrupt(<<msb::6, 1::1, _::1>>) do
    MMU.write(0xFFFF, <<msb <<< 2>>)
    0x48
  end

  # Timer
  def interrupt(<<msb::5, 1::1, _::2>>) do
    MMU.write(0xFFFF, <<msb <<< 3>>)
    0x50
  end

  # Serial
  def interrupt(<<msb::4, 1::1, _::3>>) do
    MMU.write(0xFFFF, <<msb <<< 4>>)
    0x58
  end

  # Joypad
  def interrupt(<<msb::3, 1::1, _::4>>) do
    MMU.write(0xFFFF, <<msb <<< 5>>)
    0x60
  end
end
