defmodule GameKun.Ops.Extended.Impl do
  use Bitwise
  alias GameKun.Ops

  # Retrieve pos from opcode
  defp pos_op(op), do: op >>> 3 &&& 7
  # Retrieve bit from pos of val
  defp bit_pos_val(val, pos), do: <<val >>> pos &&& 1>>

  def rlc(val) do
    rlc = <<val <<< 1 ||| val >>> 7>>
    z = Ops.z_f(rlc)
    c = val >>> 3 &&& 0x10
    flags = <<z ||| c>>
    {rlc, flags}
  end

  def rrc(val) do
    rrc = <<val >>> 1 ||| val <<< 7>>
    z = Ops.z_f(rrc)
    c = val <<< 4 &&& 0x10
    flags = <<z ||| c>>
    {rrc, flags}
  end

  def rl(val, carry) do
    rl = <<val <<< 1 ||| carry>>
    z = Ops.z_f(rl)
    c = val >>> 3 &&& 0x10
    flags = <<z ||| c>>
    {rl, flags}
  end

  def rr(val, carry) do
    rr = <<val >>> 1 ||| carry>>
    z = Ops.z_f(rr)
    c = val <<< 4 &&& 0x10
    flags = <<z ||| c>>
    {rr, flags}
  end

  def sla(val) do
    sla = <<val <<< 1>>
    z = Ops.z_f(sla)
    c = val >>> 3 &&& 0x10
    flags = <<z ||| c>>
    {sla, flags}
  end

  def sra(val) do
    sra = <<val >>> 1 ||| (val &&& 0x80)>>
    z = Ops.z_f(sra)
    c = val <<< 4 &&& 0x10
    flags = <<z ||| c>>
    {sra, flags}
  end

  def swap(val) do
    swapped = <<val <<< 4 ||| val >>> 4>>
    z = Ops.z_f(swapped)
    flags = <<z>>
    {swapped, flags}
  end

  def srl(val) do
    sra = <<val >>> 1>>
    z = Ops.z_f(sra)
    c = val <<< 4 &&& 0x10
    flags = <<z ||| c>>
    {sra, flags}
  end

  def bit(op, val, state) do
    pos = pos_op(op)
    bit = bit_pos_val(val, pos)
    z = Ops.z_f(bit)
    c = :binary.decode_unsigned(state[6]) &&& 0x10
    <<z ||| 32 ||| c>>
  end

  def set(op, val, set) do
    pos = pos_op(op)
    above = 7 - pos
    <<a::size(above), _b::1, c::size(pos)>> = <<val>>
    <<a::size(above), set::1, c::size(pos)>>
  end
end
