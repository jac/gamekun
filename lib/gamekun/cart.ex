defmodule GameKun.Cart do

  use GenServer

  def init(rom_path) do
    {:ok, rom_path}
  end
end
