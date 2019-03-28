defmodule GameKun.MMU do
  alias GameKun.Cart
  alias GameKun.RAM
  alias GameKun.GPU
  alias GameKun.Timer

  def read(pos) when pos in 0x8000..0x9FFF, do: GPU.read(pos)
  def read(pos) when pos in 0xFE00..0xFE9F, do: GPU.read(pos)
  def read(pos) when pos in 0xFEA0..0xFEFF, do: <<0xFF>>
  def read(pos) when pos in 0xFF04..0xFF07, do: Timer.read(pos)
  def read(pos, len \\ 1)
  def read(pos, len) when pos in 0x0000..0x7FFF, do: Cart.read(pos, len)
  def read(pos, len) when pos in 0xA000..0xBFFF, do: Cart.read(pos, len)
  def read(pos, len) when pos in 0xC000..0xDFFF, do: RAM.read(pos, len)
  def read(pos, len) when pos in 0xE000..0xFDFF, do: RAM.read(pos - 0x2000, len)
  def read(pos, len) when pos in 0xFF00..0xFFFF, do: RAM.read(pos, len)

  def write(pos, val) when pos in 0x0000..0x7FFF, do: Cart.write(pos, val)
  def write(pos, val) when pos in 0x8000..0x9FFF, do: GPU.write(pos, val)
  def write(pos, val) when pos in 0xA000..0xBFFF, do: Cart.write(pos, val)
  def write(pos, val) when pos in 0xC000..0xDFFF, do: RAM.write(pos, val)
  def write(pos, val) when pos in 0xE000..0xFDFF, do: RAM.write(pos - 0x2000, val)
  def write(pos, val) when pos in 0xFE00..0xFE9F, do: GPU.write(pos, val)
  def write(pos, _val) when pos in 0xFEA0..0xFEFF, do: nil
  def write(pos, val) when pos in 0xFF04..0xFF07, do: Timer.write(pos, val)
  def write(0xFF00, _val), do: nil
  def write(pos, val) when pos in 0xFF01..0xFFFF, do: RAM.write(pos, val)
end
