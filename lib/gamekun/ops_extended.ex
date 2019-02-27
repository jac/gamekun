defmodule GameKun.Ops.Extended do
  use Bitwise
  alias GameKun.MMU
  alias GameKun.Ops.Extended.Impl

  def decode(<<op>>, cpu_state) do
    cpu_state = %{cpu_state | pc: cpu_state.pc + 1, cycles: cpu_state.cycles + 4}
    execute(op, cpu_state)
  end

  defp reg_from_op(op) do
    op &&& 7
  end

  def reg_val(op, state) do
    reg = reg_from_op(op)
    <<val>> = state[reg]
    {reg, val}
  end

  # Get address and val of memory location pointed to by HL
  def pos_val_hl(cpu_state) do
    <<address::16>> = cpu_state[4] <> cpu_state[5]
    <<val>> = MMU.read(address)
    {address, val}
  end

  # rlc (hl)
  def execute(0x06, state) do
    {pos, val} = pos_val_hl(state)
    {rlc, flags} = Impl.rlc(val)
    MMU.write(pos, rlc)
    %{state | 6 => flags, cycles: state.cycles + 8}
  end

  # rlc reg
  def execute(op, state) when op <= 0x07 do
    {reg, val} = reg_val(op, state)
    {rlc, flags} = Impl.rlc(val)
    %{state | reg => rlc, 6 => flags}
  end

  # rrc (hl)
  def execute(0x0E, state) do
    {pos, val} = pos_val_hl(state)
    {rrc, flags} = Impl.rrc(val)
    MMU.write(pos, rrc)
    %{state | 6 => flags, cycles: state.cycles + 8}
  end

  # rrc reg
  def execute(op, state) when op <= 0x0F do
    {reg, val} = reg_val(op, state)
    {rrc, flags} = Impl.rrc(val)
    %{state | reg => rrc, 6 => flags}
  end

  # rl (hl)
  def execute(0x16, state) do
    {pos, val} = pos_val_hl(state)
    carry = :binary.decode_unsigned(state[6]) >>> 4 &&& 1
    {rl, flags} = Impl.rl(val, carry)
    MMU.write(pos, rl)
    %{state | 6 => flags, cycles: state.cycles + 8}
  end

  # rl reg
  def execute(op, state) when op <= 0x17 do
    {reg, val} = reg_val(op, state)
    carry = :binary.decode_unsigned(state[6]) >>> 4 &&& 1
    {rl, flags} = Impl.rl(val, carry)
    %{state | reg => rl, 6 => flags}
  end

  # rr (hl)
  def execute(0x1E, state) do
    {pos, val} = pos_val_hl(state)
    carry = :binary.decode_unsigned(state[6]) <<< 3 &&& 0x80
    {rr, flags} = Impl.rr(val, carry)
    MMU.write(pos, rr)
    %{state | 6 => flags, cycles: state.cycles + 8}
  end

  # rr reg
  def execute(op, state) when op <= 0x1F do
    {reg, val} = reg_val(op, state)
    carry = :binary.decode_unsigned(state[6]) <<< 3 &&& 0x80
    {rr, flags} = Impl.rr(val, carry)
    %{state | reg => rr, 6 => flags}
  end

  # sla (hl)
  def execute(0x26, state) do
    {pos, val} = pos_val_hl(state)
    {sla, flags} = Impl.sla(val)
    MMU.write(pos, sla)
    %{state | 6 => flags, cycles: state.cycles + 8}
  end

  # sla reg
  def execute(op, state) when op <= 0x27 do
    {reg, val} = reg_val(op, state)
    {sla, flags} = Impl.sla(val)
    %{state | reg => sla, 6 => flags}
  end

  # sra (hl)
  def execute(0x2E, state) do
    {pos, val} = pos_val_hl(state)
    {sra, flags} = Impl.sra(val)
    MMU.write(pos, sra)
    %{state | 6 => flags, cycles: state.cycles + 8}
  end

  # sra reg
  def execute(op, state) when op <= 0x2F do
    {reg, val} = reg_val(op, state)
    {sra, flags} = Impl.sra(val)
    %{state | reg => sra, 6 => flags}
  end

  # swap (hl)
  def execute(0x36, state) do
    {pos, val} = pos_val_hl(state)
    {swapped, flags} = Impl.swap(val)
    MMU.write(pos, swapped)
    %{state | 6 => flags, cycles: state.cycles + 8}
  end

  # swap reg
  def execute(op, state) when op <= 0x37 do
    {reg, val} = reg_val(op, state)
    {swapped, flags} = Impl.swap(val)
    %{state | reg => swapped, 6 => flags}
  end

  # srl (hl)
  def execute(0x3E, state) do
    {pos, val} = pos_val_hl(state)
    {srl, flags} = Impl.srl(val)
    MMU.write(pos, srl)
    %{state | 6 => flags, cycles: state.cycles + 8}
  end

  # srl reg
  def execute(op, state) when op <= 0x3F do
    {reg, val} = reg_val(op, state)
    {srl, flags} = Impl.srl(val)
    %{state | reg => srl, 6 => flags}
  end

  # bit n, (hl)
  def execute(op, state) when op <= 0x7F and (op &&& 0x07) == 6 do
    {_pos, val} = pos_val_hl(state)
    flags = Impl.bit(op, val, state)
    %{state | 6 => flags, cycles: state.cycles + 8}
  end

  # bit n, reg
  def execute(op, state) when op <= 0x7F do
    {_reg, val} = reg_val(op, state)
    flags = Impl.bit(op, val, state)
    %{state | 6 => flags}
  end

  # res n, (hl)
  def execute(op, state) when op <= 0xBF and (op &&& 0x07) == 6 do
    {pos, val} = pos_val_hl(state)
    res = Impl.set(op, val, 0)
    MMU.write(pos, res)
    %{state | cycles: state.cycles + 8}
  end

  # res pos, reg
  def execute(op, state) when op <= 0xBF do
    {reg, val} = reg_val(op, state)
    res = Impl.set(op, val, 0)
    %{state | reg => res}
  end

  # set n, (hl)
  def execute(op, state) when op <= 0xFF and (op &&& 0x07) == 6 do
    {pos, val} = pos_val_hl(state)
    set = Impl.set(op, val, 1)
    MMU.write(pos, set)
    %{state | cycles: state.cycles + 8}
  end

  # set pos, reg
  def execute(op, state) when op <= 0xFF do
    {reg, val} = reg_val(op, state)
    set = Impl.set(op, val, 1)
    %{state | reg => set}
  end
end
