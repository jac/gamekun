defmodule GameKun.Ops do
  use Bitwise
  alias GameKun.Ops.Extended
  alias GameKun.MMU
  alias GameKun.Ops.Impl

  def decode(<<op>>, cpu_state) do
    cpu_state = %{cpu_state | pc: cpu_state.pc + 1, cycles: cpu_state.cycles + 4}
    execute(op, cpu_state)
  end

  defp hl_p(state) do
    <<pos::16>> = state[4] <> state[5]
    <<val>> = MMU.read(pos)
    val
  end

  ## Operations

  # nop
  def execute(0x00, state) do
    state
  end

  # stop
  def execute(0x10, _state) do
    exit({:shutdown, 0})
  end

  # jr r8
  def execute(0x18, state) do
    {pc, cycles} = Impl.jump_r8(state)
    %{state | pc: pc, cycles: cycles}
  end

  # jr nz//z//nc//c, r8
  def execute(op, state) when op in [0x20, 0x28, 0x30, 0x38] do
    {pc, cycles} = Impl.jump_r8_cond(op, state)
    %{state | pc: pc, cycles: cycles}
  end

  # ld bc|de|hl, d16 (0x01,0x11,0x21)
  def execute(op, state) when op <= 0x21 and rem(op, 0x10) == 1 do
    [{reg1, reg2}, {val1, val2}, pc, cycles] = Impl.load_d16(op, state)
    %{state | reg1 => val1, reg2 => val2, pc: pc, cycles: cycles}
  end

  # ld (bc)|(de)|(hl+)|(hl-), a (0x02,0x12,0x22,0x32)
  def execute(op, state) when op <= 0x32 and rem(op, 0x10) == 2 do
    [{reg1, reg2}, <<val1, val2>>, cycles] = Impl.load_reg16_a(op, state)
    %{state | reg1 => <<val1>>, reg2 => <<val2>>, cycles: cycles}
  end

  # ld a, (bc)|(de)|(hl+)|(hl-) (0x0a,0x1a,0x2a,03a)
  def execute(op, state) when op <= 0x3A and rem(op, 0x10) == 0xA do
    [{reg1, reg2}, val, <<val1, val2>>, cycles] = Impl.load_a_reg16(op, state)
    %{state | reg1 => <<val1>>, reg2 => <<val2>>, 7 => val, cycles: cycles}
  end

  # rlc//rrc a
  def execute(op, state) when op in [0x07, 0x0F] do
    {result, flags} = Impl.rlc_rrc(op, state)
    %{state | 6 => flags, 7 => result}
  end

  # rl//rr a
  def execute(op, state) when op in [0x17, 0x1F] do
    {result, flags} = Impl.rl_rr(op, state)
    %{state | 6 => flags, 7 => result}
  end

  # daa
  def execute(0x27, state) do
    {daa, flags} = Impl.daa(state)
    %{state | 6 => flags, 7 => daa}
  end

  # cpl
  def execute(0x2F, state) do
    {cpl, flags} = Impl.cpl(state)
    %{state | 6 => flags, 7 => cpl}
  end

  # scf
  def execute(0x37, state) do
    flags = Impl.scf(state)
    %{state | 6 => flags}
  end

  # ccf
  def execute(0x3F, state) do
    flags = Impl.ccf(state)
    %{state | 6 => flags}
  end

  # inc//dec bc|de|hl (0x03/B,0x13/B,0x23/B)
  def execute(op, state) when op <= 0x2B and rem(op, 0x10) in [0x3, 0xB] do
    [{reg1, reg2}, <<val1, val2>>, cycles] = Impl.arit_16(op, state)
    %{state | reg1 => <<val1>>, reg2 => <<val2>>, cycles: cycles}
  end

  # ld sp, d16
  def execute(0x31, state) do
    [{_reg1, _reg2}, {val1, val2}, pc, cycles] = Impl.load_d16(0x31, state)
    sp = :binary.decode_unsigned(val1 <> val2)
    %{state | sp: sp, pc: pc, cycles: cycles}
  end

  # inc//dec sp
  def execute(op, state) when op in [0x33, 0x3B] do
    change = if (op &&& 0x08) == 0x08, do: -1, else: 1
    %{state | sp: state.sp + change, cycles: state.cycles + 4}
  end

  # inc//dec (hl)
  def execute(op, state) when op in [0x34, 0x35] do
    {flags, cycles} = Impl.inc_dec_hl_p(op, state)
    %{state | 6 => flags, cycles: cycles}
  end

  # inc//dec reg8 (0x04/5,0x0C/D,0x14/5,0x1C/D,0x24/5,0x2C/D,0x3C/D)
  def execute(op, state) when op <= 0x3D and rem(op, 0x10) in [0x04, 0x05, 0x0C, 0x0D] do
    {reg, inc, flags} = Impl.arit_8_op(op, state)
    %{state | reg => inc, 6 => flags}
  end

  # ld (hl), d8
  def execute(0x36, state) do
    <<pos::16>> = state[4] <> state[5]
    [{_reg, val}, pc, _cycles] = Impl.load_d8(0x36, state)
    MMU.write(pos, val)
    %{state | pc: pc, cycles: state.cycles + 8}
  end

  # ld reg, d8
  def execute(op, state) when op <= 0x3E and rem(op, 0x10) in [0x06, 0x0E] do
    [{reg, val}, pc, cycles] = Impl.load_d8(op, state)
    %{state | reg => val, pc: pc, cycles: cycles}
  end

  # ld (a16), sp
  def execute(0x08, state) do
    Impl.a16_sp(state)
    %{state | pc: state.pc + 2, cycles: state.cycles + 16}
  end

  # add hl, bc//de//hl
  def execute(op, state) when op <= 0x2B and rem(op, 0x10) == 0x09 do
    {<<h, l>>, flags, cycles} = Impl.add_hl_op(op, state)
    %{state | 4 => <<h>>, 5 => <<l>>, 6 => flags, cycles: cycles}
  end

  # add hl, sp
  def execute(0x39, state) do
    {<<h, l>>, flags, cycles} = Impl.add_hl_val(state.sp, state)
    %{state | 4 => <<h>>, 5 => <<l>>, 6 => flags, cycles: cycles}
  end

  # halt
  def execute(0x76, state) do
    Impl.halt()
    state
  end

  # ld (hl), reg
  def execute(op, state) when op in 0x70..0x77 do
    cycles = Impl.load_hl_p_reg(op, state)
    %{state | cycles: cycles}
  end

  # ld reg, (hl)
  def execute(op, state) when op < 0x7F and rem(op, 0x10) in [0x06, 0x0E] do
    {reg, val, cycles} = Impl.load_reg_hl_p(op, state)
    %{state | reg => val, cycles: cycles}
  end

  # ld reg, reg
  def execute(op, state) when op <= 0x7F do
    {reg, val} = Impl.load_reg_reg(op, state)
    %{state | reg => val}
  end

  # add a, (hl)
  def execute(0x86, state) do
    val = hl_p(state)
    {result, flags} = Impl.add_8_val(val, state)
    %{state | 6 => flags, 7 => result, cycles: state.cycles + 4}
  end

  # add a, reg
  def execute(op, state) when op in 0x80..0x87 do
    {result, flags} = Impl.add_8_op(op, state)
    %{state | 6 => flags, 7 => result}
  end

  # add a, d8
  def execute(0xC6, state) do
    <<val>> = MMU.read(state.pc)
    {result, flags} = Impl.add_8_val(val, state)
    %{state | 6 => flags, 7 => result, pc: state.pc + 1, cycles: state.cycles + 4}
  end

  # adc A, (hl)
  def execute(0x8E, state) do
    val = hl_p(state)
    <<carry>> = state[6]
    {result, flags} = Impl.add_8_val(val, state, carry)
    %{state | 6 => flags, 7 => result, cycles: state.cycles + 4}
  end

  # adc A, reg
  def execute(op, state) when op in 0x88..0x8F do
    <<carry>> = state[6]
    {result, flags} = Impl.add_8_op(op, state, carry)
    %{state | 6 => flags, 7 => result}
  end

  # adc a, d8
  def execute(0xCE, state) do
    <<val>> = MMU.read(state.pc)
    <<carry>> = state[6]
    {result, flags} = Impl.add_8_val(val, state, carry)
    %{state | 6 => flags, 7 => result, pc: state.pc + 1, cycles: state.cycles + 4}
  end

  # sub A, (hl)
  def execute(0x96, state) do
    val = hl_p(state)
    {result, flags} = Impl.sub_8_val(val, state)
    %{state | 6 => flags, 7 => result, cycles: state.cycles + 4}
  end

  # sub A, reg
  def execute(op, state) when op in 0x90..0x97 do
    {result, flags} = Impl.sub_8_op(op, state)
    %{state | 6 => flags, 7 => result}
  end

  # sub a, d8
  def execute(0xD6, state) do
    <<val>> = MMU.read(state.pc)
    {result, flags} = Impl.sub_8_val(val, state)
    %{state | 6 => flags, 7 => result, pc: state.pc + 1, cycles: state.cycles + 4}
  end

  # sbc A, (hl)
  def execute(0x9E, state) do
    <<carry>> = state[6]
    val = hl_p(state)
    {result, flags} = Impl.sub_8_val(val, state, carry)
    %{state | 6 => flags, 7 => result, cycles: state.cycles + 4}
  end

  # sbc A, reg
  def execute(op, state) when op in 0x98..0x9F do
    <<carry>> = state[6]
    {result, flags} = Impl.sub_8_op(op, state, carry)
    %{state | 6 => flags, 7 => result}
  end

  # sbc a, d8
  def execute(0xDE, state) do
    <<carry>> = state[6]
    <<val>> = MMU.read(state.pc)
    {result, flags} = Impl.sub_8_val(val, state, carry)
    %{state | 6 => flags, 7 => result, pc: state.pc + 1, cycles: state.cycles + 4}
  end

  # and A, (hl)
  def execute(0xA6, state) do
    val = hl_p(state)
    {result, flags} = Impl.and_8_val(val, state)
    %{state | 6 => flags, 7 => result, cycles: state.cycles + 4}
  end

  # and A, reg
  def execute(op, state) when op in 0xA0..0xA7 do
    {result, flags} = Impl.and_8_op(op, state)
    %{state | 6 => flags, 7 => result}
  end

  # and a, d8
  def execute(0xE6, state) do
    <<val>> = MMU.read(state.pc)
    {result, flags} = Impl.and_8_val(val, state)
    %{state | 6 => flags, 7 => result, pc: state.pc + 1, cycles: state.cycles + 4}
  end

  # xor A, (hl)
  def execute(0xAE, state) do
    val = hl_p(state)
    {result, flags} = Impl.xor_8_val(val, state)
    %{state | 6 => flags, 7 => result, cycles: state.cycles + 4}
  end

  # xor A, reg
  def execute(op, state) when op in 0xA8..0xAF do
    {result, flags} = Impl.xor_8_op(op, state)
    %{state | 6 => flags, 7 => result}
  end

  # xor a, d8
  def execute(0xEE, state) do
    <<val>> = MMU.read(state.pc)
    {result, flags} = Impl.xor_8_val(val, state)
    %{state | 6 => flags, 7 => result, pc: state.pc + 1, cycles: state.cycles + 4}
  end

  # or A, (hl)
  def execute(0xB6, state) do
    val = hl_p(state)
    {result, flags} = Impl.or_8_val(val, state)
    %{state | 6 => flags, 7 => result, cycles: state.cycles + 4}
  end

  # or A, reg
  def execute(op, state) when op in 0xB0..0xB7 do
    {result, flags} = Impl.or_8_op(op, state)
    %{state | 6 => flags, 7 => result}
  end

  # or a, d8
  def execute(0xF6, state) do
    <<val>> = MMU.read(state.pc)
    {result, flags} = Impl.or_8_val(val, state)
    %{state | 6 => flags, 7 => result, pc: state.pc + 1, cycles: state.cycles + 4}
  end

  # cp A, (hl)
  def execute(0xBE, state) do
    val = hl_p(state)
    flags = Impl.cp_8_val(val, state)
    %{state | 6 => flags, cycles: state.cycles + 4}
  end

  # cp A, reg
  def execute(op, state) when op in 0xB8..0xBF do
    flags = Impl.cp_8_op(op, state)
    %{state | 6 => flags}
  end

  # ret nz//z//nc//z
  def execute(op, state) when op in [0xC0, 0xC8, 0xD0, 0xD8] do
    {pc, sp, _ime, cycles} = Impl.ret_cond(op, state)
    %{state | pc: pc, sp: sp, cycles: cycles}
  end

  # jmp a16
  def execute(0xC3, state) do
    {pc, cycles} = Impl.jump_a16(state)
    %{state | pc: pc, cycles: cycles}
  end

  # jmp nz//z//nc//c, a16
  def execute(op, state) when op in [0xC2, 0xCA, 0xD2, 0xDA] do
    {pc, cycles} = Impl.jump_a16_cond(op, state)
    %{state | pc: pc, cycles: cycles}
  end

  # pop BC//DE//HL//AF
  def execute(op, state) when op > 0xC0 and rem(op, 0x10) == 1 do
    [{reg1, reg2}, {val1, val2, sp}, cycles] = Impl.pop_16(op, state)
    %{state | reg1 => val1, reg2 => val2, sp: sp, cycles: cycles}
  end

  # call nz/z/nc/c
  def execute(op, state) when op in [0xC4, 0xCC, 0xD4, 0xDC] do
    {pc, sp, cycles} = Impl.call_cond(op, state)
    %{state | pc: pc, sp: sp, cycles: cycles}
  end

  # push BC//DE//HL//AF
  def execute(op, state) when op > 0xC4 and rem(op, 0x10) == 5 do
    {sp, cycles} = Impl.push_16(op, state)
    %{state | sp: sp, cycles: cycles}
  end

  # rst nn
  def execute(op, state) when op > 0xC6 and rem(op, 0x10) in [7, 0xF] do
    {pc, sp, cycles} = Impl.rst(op, state)
    %{state | pc: pc, sp: sp, cycles: cycles}
  end

  # ret
  def execute(op, state) when op in [0xC9, 0xD9] do
    {pc, sp, ime, cycles} = Impl.ret(op, state)
    %{state | pc: pc, sp: sp, ime: ime, cycles: cycles}
  end

  # call a16
  def execute(0xCD, state) do
    {pc, sp, cycles} = Impl.call(state)
    %{state | pc: pc, cycles: cycles, sp: sp}
  end

  # PREFIX CB
  def execute(0xCB, state) do
    MMU.read(state.pc)
    |> Extended.decode(state)
  end

  # ldh (a8), a
  def execute(0xE0, state) do
    {pc, cycles} = Impl.ldh_a8_a(state)
    %{state | pc: pc, cycles: cycles}
  end

  # add sp, r8
  def execute(0xE8, state) do
    {sp, flags, pc, cycles} = Impl.add_sp_r8(state)
    %{state | 6 => flags, pc: pc, cycles: cycles, sp: sp}
  end

  # jmp (hl)
  def execute(0xE9, state) do
    pc = Impl.hl(state)
    %{state | pc: pc}
  end

  # ldh a, (a8)
  def execute(0xF0, state) do
    {pc, cycles, a} = Impl.ldh_a_a8(state)
    %{state | 7 => a, pc: pc, cycles: cycles}
  end

  # ldh (c), a
  def execute(0xE2, state) do
    {pc, cycles} = Impl.ldh_c_a(state)
    %{state | pc: pc, cycles: cycles}
  end

  # ld (a16), a
  def execute(0xEA, state) do
    {pc, cycles} = Impl.load_a16_a(state)
    %{state | pc: pc, cycles: cycles}
  end

  # ldh a, (c)
  def execute(0xF2, state) do
    {pc, cycles, val} = Impl.ldh_a_c(state)
    %{state | 7 => val, pc: pc, cycles: cycles}
  end

  # di
  def execute(0xF3, state) do
    %{state | ime: 0}
  end

  # ld hl, sp + r8
  def execute(0xF8, state) do
    {[h, l], cycles, flags} = Impl.hl_sp(state)
    %{state | 4 => h, 5 => l, 6 => flags, cycles: cycles}
  end

  # ld sp, hl
  def execute(0xF9, state) do
    sp = Impl.hl(state)
    %{state | sp: sp, cycles: state.cycles + 4}
  end

  # ld a, (a16)
  def execute(0xFA, state) do
    {a, pc, cycles} = Impl.load_a_a16(state)
    %{state | 7 => a, pc: pc, cycles: cycles}
  end

  # cp a, d8
  def execute(0xFE, state) do
    <<val>> = MMU.read(state.pc)
    flags = Impl.cp_8_val(val, state)
    %{state | 6 => flags, pc: state.pc + 1, cycles: state.cycles + 4}
  end

  # ie
  def execute(0xFB, state) do
    %{state | ime: 1}
  end

  def execute(op, _cpu_state) do
    raise("Unimplemented Operation 0x#{Integer.to_string(op, 16)}")
  end
end
