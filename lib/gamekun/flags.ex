defmodule GameKun.Flags do
  use Bitwise

  def z_f(<<0>>), do: 128
  def z_f(_n), do: 0

  def c_f_8(n, arg1, arg2, carry \\ 0)

  def c_f_8(0, arg1, arg2, carry) do
    (arg1 + arg2 + carry &&& 0x100) >>> 4
  end

  def c_f_8(1, arg1, arg2, carry) do
    if arg1 < arg2 + carry, do: 0x10, else: 0
  end

  def h_f_8(n, arg1, arg2, carry \\ 0)

  def h_f_8(0, arg1, arg2, carry) do
    ((arg1 &&& 0xF) + (arg2 &&& 0xF) + carry &&& 0x10) <<< 1
  end

  def h_f_8(1, arg1, arg2, carry) do
    if (arg1 &&& 0xF) < (arg2 &&& 0xF) + carry, do: 0x20, else: 0
  end

  def c_f_16(0, arg1, arg2) do
    (arg1 + arg2) >>> 12 &&& 0x10
  end

  def h_f_16(0, arg1, arg2) do
    ((arg1 &&& 0x0FFF) + (arg2 &&& 0x0FFF)) >>> 7 &&& 0x20
  end
end
