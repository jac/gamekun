defmodule GameKun.CPU do
  use GenServer
  alias __MODULE__, as: CPU_S
  defstruct af: 0x00, bc: 0x00, de: 0x00, hl: 0x00, pc: 0x100, sp: 0xFFFE, cycle: 0

  # API
  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: CPU)
  end

  # Server
  def init(_args) do
    Process.send_after(CPU, :begin, 0)
    {:ok, %CPU_S{}}
  end

  def handle_cast(:process, cpu_state) do
    # HANDLE OPERATION
    case Process.info(Process.whereis(CPU), :message_queue_len) do
      {_, n} when n > 0 ->
        send(CPU, :interrupt)

      _ ->
        GenServer.cast(CPU, :process)
    end

    {:noreply, cpu_state}
  end

  def handle_info(:interrupt, cpu_state) do
    {:noreply, cpu_state}
  end

  def handle_info(:begin, cpu_state) do
    GenServer.cast(CPU, :process)
    {:noreply, cpu_state}
  end
end
