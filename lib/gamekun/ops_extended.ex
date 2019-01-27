defmodule GameKun.Ops.Extended do

  use Bitwise
  alias GameKun.Ops

  def decode(<<op>>, cpu_state) do
    cpu_state = %{cpu_state | pc: cpu_state.pc + 1, cycles: cpu_state.cycles + 4}
    execute(op, cpu_state)
  end

  defp reg_from_op(op), do: op &&& 7
  defp bit_pos(op), do: op >>> 3 &&& 7
  defp reg_val(op,state) do
    reg = reg_from_op(op)
    <<val>> = state[reg]
    {reg, val}
  end

  defp bit_pos(val, pos) do
    <<(val >>> pos) &&& 1>>
  end


  # rlc reg
  def execute(op, state) when op in 0x00..0x06 or op == 0x07 do
    {reg, val} = reg_val(op, state)
    rlc = <<(val <<< 1) ||| (val >>> 7)>>
    z = Ops.z_f(rlc)
    c = val >>> 3 &&& 0x10
    %{state | reg => rlc, 6 => <<z ||| c>>}
  end

  # rrc reg
  def execute(op, state) when op in 0x08..0x0D or op == 0x0F do
    {reg, val} = reg_val(op, state)
    rrc = <<(val >>> 1) ||| (val <<< 7)>>
    z = Ops.z_f(rrc)
    c = val <<< 4 &&& 0x10
    %{state | reg => rrc, 6 => <<z ||| c>>}
  end

  # rl reg
  def execute(op, state) when op in 0x10..0x16 or op == 0x17 do
    {reg, val} = reg_val(op, state)
    carry = (:binary.decode_unsigned(state[6]) >>> 4) &&& 1
    rl = <<(val <<< 1) ||| carry>>
    z = Ops.z_f(rl)
    c = val >>> 3 &&& 0x10
    %{state | reg => rl, 6 => <<z ||| c>>}
  end

  # rr reg
  def execute(op, state) when op in 0x18..0x1D or op == 0x1F do
    {reg, val} = reg_val(op, state)
    carry = (:binary.decode_unsigned(state[6]) <<< 3) &&& 0x80
    rr = <<(val >>> 1) ||| carry>>
    z = Ops.z_f(rr)
    c = val <<< 4 &&& 0x10
    %{state | reg => rr, 6 => <<z ||| c>>}
  end

  #sla reg
  def execute(op, state) when op in 0x20..0x25 or op == 0x27 do
    {reg, val} = reg_val(op, state)
    sla = <<val <<< 1>>
    z = Ops.z_f(sla)
    c = val >>> 3 &&& 0x10
    %{state | reg => sla, 6 => <<z ||| c>>}
  end

  #sra reg
  def execute(op, state) when op in 0x28..0x2D or op == 0x2F do
    {reg, val} = reg_val(op, state)
    sra = <<val >>> 1 ||| val &&& 0x80>>
    z = Ops.z_f(sra)
    c = val <<< 4 &&& 0x10
    %{state | reg => sra, 6 => <<z ||| c>>}
  end

  #swap reg
  def execute(op, state) when op in 0x30..0x35 or op == 0x37 do
    {reg, val} = reg_val(op, state)
    swapped = <<val <<< 4 ||| val >>> 4>>
    z = Ops.z_f(swapped)
    %{state | reg => swapped, 6 => <<z>>}
  end

  #srl reg
  def execute(op, state) when op in 0x38..0x3D or op == 0x3F do
    {reg, val} = reg_val(op, state)
    sra = <<val >>> 1>>
    z = Ops.z_f(sra)
    c = val <<< 4 &&& 0x10
    %{state | reg => sra, 6 => <<z ||| c>>}
  end

  # bit pos, reg
  def execute(op, state) when op in 0x40..0x7F and rem(op, 0x10) not in [6,14] do
    {_reg, val} = reg_val(op, state)
    pos = bit_pos(op)
    z = Ops.z_f(bit_pos(val, pos))
    carry = :binary.decode_unsigned(state[6]) &&& 0x10
    %{state | 6 => <<z ||| 32 ||| carry>>}
  end

  # res pos, reg
  def execute(op, state) when op in 0x80..0xBF and rem(op, 0x10) not in [6,14] do
    {reg, val} = reg_val(op, state)
    pos = bit_pos(op)
    above = 7 - pos
    below = pos
    <<a::size(above), _b::1, c::size(below)>> = <<val>>
    set = <<a::size(above), 0::1, c::size(below)>>
    %{state | reg => set}
  end

  #set pos, reg
  def execute(op, state) when op in 0xC0..0xFF and rem(op, 0x10) not in [6,14] do
    {reg, val} = reg_val(op, state)
    pos = bit_pos(op)
    above = 7 - pos
    below = pos
    <<a::size(above), _b::1, c::size(below)>> = <<val>>
    set = <<a::size(above), 1::1, c::size(below)>>
    %{state | reg => set}
  end

  def execute(op, _state) do
    raise("Unimplemented Operation #{Integer.to_string(op, 16)}")
  end
end
