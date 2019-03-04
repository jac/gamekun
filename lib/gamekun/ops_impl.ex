defmodule GameKun.Ops.Impl do
  use Bitwise
  alias GameKun.Flags
  alias GameKun.Ops.Extended.Impl, as: ExImpl
  alias GameKun.MMU

  ### Helper Functions

  # Retrieve value from reg determined by Opcode
  def arit_val(op, state) do
    src = op &&& 0x07
    <<val>> = state[src]
    val
  end

  # Adjust nibble to bcd compliancy
  defp bcd_adjust(val, flag \\ 0) do
    if (val &&& 0x0F) > 9 or flag == 1 do
      {val + 0x06 &&& 0x0F, 1}
    else
      {val, 0}
    end
  end

  # Extract Register from Opcode
  defp reg_16(op) do
    reg1 = (op ^^^ 0xC1) >>> 3
    reg2 = reg1 + 1
    {reg1, reg2}
  end

  # Extract registers from Opcode capped at HL (4,5)
  defp reg16_capped(op) do
    reg1 = if op > 0x2B, do: 4, else: op >>> 4 <<< 1
    reg2 = reg1 + 1
    {reg1, reg2}
  end

  # Implement NZ/Z/C/NZ conditional logic
  defp mask_cond(op, state) do
    <<flags>> = state[6]
    mask = if (op &&& 0x10) == 0x10, do: 0x10, else: 0x80
    cond_func = if (op &&& 0x08) == 0x08, do: &Kernel.==/2, else: &Kernel.!=/2
    (flags &&& mask) |> cond_func.(mask)
  end

  ### Implementation

  def load_d8(op, state) do
    val = MMU.read(state.pc)
    reg = op >>> 3
    [{reg, val}, state.pc + 1, state.cycles + 4]
  end

  def load_hl_p_reg(op, state) do
    src = op &&& 7
    val = state[src]
    <<pos::16>> = state[4] <> state[5]
    MMU.write(pos, val)
    state.cycles + 4
  end

  def load_reg_hl_p(op, state) do
    <<pos::16>> = state[4] <> state[5]
    val = MMU.read(pos)
    reg = op >>> 3 &&& 7
    {reg, val, state.cycles + 4}
  end

  def load_reg_reg(op, state) do
    dest = op >>> 3 &&& 7
    src = op &&& 7
    val = state[src]
    {dest, val}
  end

  def load_d16(op, state) do
    <<v2, v1>> = MMU.read(state.pc, 2)
    reg1 = op >>> 3
    reg2 = reg1 + 1
    [{reg1, reg2}, {<<v1>>, <<v2>>}, state.pc + 2, state.cycles + 8]
  end

  def load_reg16_a(op, state) do
    {reg1, reg2} = reg16_capped(op)
    <<pos::16>> = state[reg1] <> state[reg2]
    MMU.write(pos, state[7])
    inc_dec = if op == 0x22, do: 1, else: if(op == 0x32, do: -1, else: 0)
    [{reg1, reg2}, <<pos + inc_dec::16>>, state.cycles + 4]
  end

  def load_a_reg16(op, state) do
    {reg1, reg2} = reg16_capped(op)
    <<pos::16>> = state[reg1] <> state[reg2]
    <<val>> = MMU.read(pos)
    inc_dec = if op == 0x2A, do: 1, else: if(op == 0x3A, do: -1, else: 0)
    [{reg1, reg2}, <<val>>, <<pos + inc_dec::16>>, state.cycles + 4]
  end

  def ldh_a8_a(state) do
    a = state[7]
    <<pos>> = MMU.read(state.pc)
    MMU.write(0xFF00 + pos, a)
    {state.pc + 1, state.cycles + 8}
  end

  def ldh_a_a8(state) do
    <<pos>> = MMU.read(state.pc)
    val = MMU.read(0xFF00 + pos)
    {state.pc + 1, state.cycles + 8, val}
  end

  def ldh_c_a(state) do
    a = state[7]
    <<pos>> = state[1]
    MMU.write(0xFF00 + pos, a)
    {state.pc, state.cycles + 4}
  end

  def ldh_a_c(state) do
    <<pos>> = state[1]
    val = MMU.read(0xFF00 + pos)
    {state.pc, state.cycles + 4, val}
  end

  def load_a16_a(state) do
    a = state[7]
    <<pos::little-integer-16>> = MMU.read(state.pc, 2)
    MMU.write(pos, a)
    {state.pc + 2, state.cycles + 12}
  end

  def load_a_a16(state) do
    <<pos::little-integer-16>> = MMU.read(state.pc, 2)
    a = MMU.read(pos)
    {a, state.pc + 2, state.cycles + 12}
  end

  def add_hl_op(op, state) do
    {reg1, reg2} = reg16_capped(op)
    <<val::16>> = state[reg1] <> state[reg2]
    add_hl_val(val, state)
  end

  def add_hl_val(val, state) do
    <<hl::16>> = state[4] <> state[5]
    sum = <<hl + val::16>>
    <<flags>> = state[6]
    z = flags &&& 0x80
    h = Flags.h_f_16(0, hl, val)
    c = Flags.c_f_16(0, hl, val)
    {sum, <<z ||| h ||| c>>, state.cycles + 4}
  end

  def a16_sp(state) do
    <<pos::little-integer-16>> = MMU.read(state.pc, 2)
    <<m_s, l_s>> = <<state.sp::16>>
    MMU.write(pos, <<l_s>>)
    MMU.write(pos + 1, <<m_s>>)
  end

  def inc_dec_hl_p(op, state) do
    type_change = if (op &&& 0x1) == 1, do: [1, -1], else: [0, 1]
    pos = :binary.decode_unsigned(state[4] <> state[5])
    <<val>> = MMU.read(pos)
    {result, flags} = arit_8_val(val, state, type_change)
    MMU.write(pos, result)
    {flags, state.cycles + 8}
  end

  def arit_8_op(op, state) do
    type_change = if (op &&& 0x1) == 1, do: [1, -1], else: [0, 1]
    reg = op >>> 3
    <<val>> = state[reg]
    {inc, flags} = arit_8_val(val, state, type_change)
    {reg, inc, flags}
  end

  def arit_8_val(val, state, [type, change]) do
    updated = <<val + change>>
    z = Flags.z_f(updated)
    n = type <<< 6
    h = Flags.h_f_8(type, val, abs(change))
    c = :binary.decode_unsigned(state[6]) &&& 0x10
    {updated, <<z ||| n ||| h ||| c>>}
  end

  def arit_16(op, state) do
    change = if (op &&& 0x0B) == 0x0B, do: -1, else: 1
    {reg1, reg2} = reg16_capped(op)
    <<inc_dec::16>> = state[reg1] <> state[reg2]
    result = <<inc_dec + change::16>>
    [{reg1, reg2}, result, state.cycles + 4]
  end

  def jump_r8(condition \\ true, state) do
    <<r8::integer-signed-8>> = MMU.read(state.pc)

    if condition do
      {state.pc + 1 + r8, state.cycles + 8}
    else
      {state.pc + 1, state.cycles + 4}
    end
  end

  def jump_r8_cond(op, state) do
    condition = mask_cond(op, state)
    jump_r8(condition, state)
  end

  def jump_a16(condition \\ true, state) do
    if condition do
      <<pc::little-integer-16>> = MMU.read(state.pc, 2)
      {pc, state.cycles + 12}
    else
      {state.pc + 2, state.cycles + 8}
    end
  end

  def jump_a16_cond(op, state) do
    condition = mask_cond(op, state)
    jump_a16(condition, state)
  end

  def hl(state) do
    <<hl::16>> = state[4] <> state[5]
    hl
  end

  def add_8_op(op, state, carry \\ 0) do
    val = arit_val(op, state)
    add_8_val(val, state, carry)
  end

  def add_8_val(val, state, carry \\ 0) do
    carry = (carry &&& 0x10) >>> 4
    <<a>> = state[7]
    result = <<a + val + carry>>
    z = Flags.z_f(result)
    h = Flags.h_f_8(0, a, val, carry)
    c = Flags.c_f_8(0, a, val, carry)
    flags = <<z ||| h ||| c>>
    {result, flags}
  end

  def sub_8_op(op, state, carry \\ 0) do
    val = arit_val(op, state)
    sub_8_val(val, state, carry)
  end

  def sub_8_val(val, state, carry \\ 0) do
    carry = (carry &&& 0x10) >>> 4
    <<a>> = state[7]
    result = <<a - val - carry>>
    z = Flags.z_f(result)
    h = Flags.h_f_8(1, a, val, carry)
    c = Flags.c_f_8(1, a, val, carry)
    flags = <<z ||| 64 ||| h ||| c>>
    {result, flags}
  end

  def and_8_op(op, state) do
    val = arit_val(op, state)
    and_8_val(val, state)
  end

  def and_8_val(val, state) do
    <<a>> = state[7]
    result = <<val &&& a>>
    z = Flags.z_f(result)
    flags = <<z ||| 32>>
    {result, flags}
  end

  def xor_8_op(op, state) do
    val = arit_val(op, state)
    xor_8_val(val, state)
  end

  def xor_8_val(val, state) do
    <<a>> = state[7]
    result = <<val ^^^ a>>
    z = Flags.z_f(result)
    flags = <<z>>
    {result, flags}
  end

  def or_8_op(op, state) do
    val = arit_val(op, state)
    or_8_val(val, state)
  end

  def or_8_val(val, state) do
    <<a>> = state[7]
    result = <<val ||| a>>
    z = Flags.z_f(result)
    flags = <<z>>
    {result, flags}
  end

  def cp_8_op(op, state) do
    val = arit_val(op, state)
    cp_8_val(val, state)
  end

  def cp_8_val(val, state) do
    <<a>> = state[7]
    result = <<a - val>>
    z = Flags.z_f(result)
    h = Flags.h_f_8(1, a, val)
    c = Flags.c_f_8(1, a, val)
    <<z ||| 0x40 ||| h ||| c>>
  end

  def daa(state) do
    <<flags, a>> = state[6] <> state[7]
    n = flags &&& 0x40
    h = flags >>> 4 &&& 1
    {lNibble, halfCarry} = bcd_adjust(a, h)
    high = (a >>> 4) + halfCarry
    {hNibble, carry} = bcd_adjust(high)
    daa = <<hNibble <<< 4 ||| lNibble>>
    z = Flags.z_f(daa)
    c = carry <<< 4
    {daa, <<z ||| n ||| c>>}
  end

  def rlc_rrc(op, state) do
    <<val>> = state[7]
    {result, <<flags>>} = if (op &&& 0xF) == 0xF, do: ExImpl.rrc(val), else: ExImpl.rlc(val)
    {result, <<flags &&& 0x10>>}
  end

  def rl_rr(op, state) do
    <<val>> = state[7]
    carry = :binary.decode_unsigned(state[6]) &&& 0x10
    carry = if op == 0x17, do: carry >>> 4, else: carry <<< 3

    {result, <<flags>>} =
      if (op &&& 0xF) == 0xF, do: ExImpl.rr(val, carry), else: ExImpl.rl(val, carry)

    flags = <<flags &&& 0x10>>
    {result, flags}
  end

  def scf(state) do
    z = :binary.decode_unsigned(state[6]) &&& 0x80
    <<z ||| 0x10>>
  end

  def ccf(state) do
    <<flags>> = state[6]
    z = flags &&& 0x80
    c = (flags &&& 0x10) ^^^ 0x10
    <<z ||| c>>
  end

  def cpl(state) do
    <<val>> = state[7]
    cpl = <<val ^^^ 0xFF>>
    c = :binary.decode_unsigned(state[6]) &&& 0x10
    z = :binary.decode_unsigned(state[6]) &&& 0x80
    #  96 =  64 ||| 32
    {cpl, <<z ||| 96 ||| c>>}
  end

  def ret(condition \\ true, op, state, {success, failure} \\ {12, 0}) do
    if condition do
      {val1, val2, sp} = pop(state)
      ime = op >>> 4 &&& 1
      <<pc::16>> = val1 <> val2
      {pc, sp, ime, state.cycles + success}
    else
      {state.pc, state.sp, state.ime, state.cycles + failure}
    end
  end

  def ret_cond(op, state) do
    condition = mask_cond(op, state)
    ret(condition, op, state, {16, 4})
  end

  def pop_16(op, state) do
    {reg1, reg2} = reg_16(op)
    {<<val1>>, <<val2>>, sp} = pop(state)
    {val1, val2} = if op < 0xF1, do: {val1, val2}, else: {val2 &&& 0xF0, val1}
    [{reg1, reg2}, {<<val1>>, <<val2>>, sp}, state.cycles + 8]
  end

  def push_16(op, state) do
    {reg1, reg2} = reg_16(op)
    <<val::16>> = if op < 0xF5, do: state[reg1] <> state[reg2], else: state[reg2] <> state[reg1]
    sp = push(val, state)
    {sp, state.cycles + 12}
  end

  def pop(state) do
    val2 = MMU.read(state.sp)
    val1 = MMU.read(state.sp + 1)
    {val1, val2, state.sp + 2}
  end

  def push(val, state) do
    <<h, l>> = <<val::16>>
    MMU.write(state.sp - 1, <<h>>)
    MMU.write(state.sp - 2, <<l>>)
    state.sp - 2
  end

  def rst(op, state) do
    pc = op ^^^ 0xC7
    sp = push(state.pc, state)
    cycles = state.cycles + 12
    {pc, sp, cycles}
  end

  def call(condition \\ true, state) do
    if condition do
      <<pc::little-integer-16>> = MMU.read(state.pc, 2)
      sp = push(state.pc + 2, state)
      {pc, sp, state.cycles + 20}
    else
      {state.pc + 2, state.sp, state.cycles + 8}
    end
  end

  def call_cond(op, state) do
    condition = mask_cond(op, state)
    call(condition, state)
  end

  def add_sp_r8(state) do
    <<val_unsigned>> = MMU.read(state.pc)
    <<val_signed::integer-signed>> = <<val_unsigned>>
    result = state.sp + val_signed
    z = Flags.z_f(<<result::16>>)
    c = Flags.c_f_8(0, state.sp &&& 0xFF, val_unsigned)
    h = Flags.h_f_8(0, state.sp &&& 0xFF, val_unsigned)
    {result, <<z ||| h ||| c>>, state.pc + 1, state.cycles + 12}
  end

  def hl_sp(state) do
    {result, flags, _pc, cycles} = add_sp_r8(state)
    <<h, l>> = <<result::16>>
    {[<<h>>, <<l>>], cycles - 4, flags}
  end

  def halt() do
    Process.whereis(CPU)
    |> send(:halt)

    :ok
  end
end
