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

  def handle_cast(:process, cpu_state) do
    cpu_state =
      cpu_state.pc
      |> GameKun.MMU.read()
      |> GameKun.Ops.decode(cpu_state)

    enabled = interrupts_enabled?(cpu_state)

    case Process.info(Process.whereis(CPU), :message_queue_len) do
      {_, n} when enabled and n > 0 ->
        nil

      _ ->
        GenServer.cast(CPU, :process)
    end

    {:noreply, cpu_state}
  end

  defp interrupts_enabled?(cpu_state) do
    cpu_state.ime == 1
  end

  def handle_info(:interrupt, cpu_state) do
    raise "Interrupts needed"
    GenServer.cast(CPU, :process)
    {:noreply, cpu_state}
  end

  def handle_info(:begin, cpu_state) do
    GenServer.cast(CPU, :process)
    {:noreply, cpu_state}
  end
end
