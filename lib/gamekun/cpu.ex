defmodule GameKun.CPU do
  use GenServer

  # API
  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: CPU)
  end

  # Server
  def init(_args) do
    Process.send_after(CPU, :begin, 0)

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
    GenServer.cast(CPU, :process)
    {:noreply, state}
  end

  def handle_info(:interrupt, state = %{ime: 0}) do
    state
  end

  def handle_info(:interrupt, state) do
    raise "Interrupts needed"
    GenServer.cast(CPU, :process)
    {:noreply, state}
  end

  def handle_info(:halt, state) do
    state
  end

  def handle_cast(:process, cpu_state) do
    state =
      cpu_state.pc
      |> GameKun.MMU.read()
      |> GameKun.Ops.decode(cpu_state)

    GenServer.cast(CPU, :process)
    {:noreply, state}
  end
end
