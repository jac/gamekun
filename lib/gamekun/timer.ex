defmodule GameKun.Timer do
  use GenServer
  use Bitwise

  # API
  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: Timer)
  end

  def read(pos) do
    GenServer.call(Timer, {:read, pos})
  end

  def write(pos, val) do
    GenServer.cast(Timer, {:write, pos, val})
  end

  def step(amt) do
    GenServer.call(Timer, {:step, amt})
  end

  # Server
  def init(_) do
    state =
      0xFF05..0xFF07
      |> Stream.zip(Stream.cycle(<<0x00>>))
      |> Stream.into(%{0xFF04 => <<0x00::16>>})

    {:ok, state}
  end

  def handle_call({:read, 0xFF04}, _from, state) do
    <<timer::16>> = state[0xFF04]
    {:reply, <<timer >>> 8>>, state}
  end

  def handle_call({:read, pos}, _from, state) do
    {:reply, state[pos], state}
  end

  # DIV
  def handle_cast({:write, 0xFF04, _val}, state) do
    {:noreply, %{state | 0xFF04 => <<0x00::16>>}}
  end

  # TAC
  def handle_cast({:write, 0xFF07, <<_::5, x::3>>}, state) do
    {:noreply, %{state | 0xFF07 => <<x>>}}
  end

  # TIMA Counter/Modulo
  def handle_cast({:write, pos, val}, state) do
    {:noreply, %{state | pos => <<val>>}}
  end
end
