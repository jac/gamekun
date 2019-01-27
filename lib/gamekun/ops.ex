defmodule GameKun.Ops do
  use Bitwise
  alias GameKun.Ops.Extended
  alias GameKun.MMU

  def decode(<<op>>, cpu_state) do
    cpu_state = %{cpu_state | pc: cpu_state.pc + 1, cycles: cpu_state.cycles + 4}
    execute(op, cpu_state)
  end

  # Flags
  def z_f(<<0>>), do: 128
  def z_f(_n), do: 0

  def c_f_8(n, arg1, arg2, carry \\ 0)

  def c_f_8(0, arg1, arg2, carry) do
    if arg1 + arg2 + carry > 255, do: 16, else: 0
  end

  def c_f_8(1, arg1, arg2, carry) do
    if arg1 - arg2 - carry < 0, do: 16, else: 0
  end

  def h_f_8(n, arg1, arg2, carry \\ 0)

  def h_f_8(0, arg1, arg2, carry) do
    if ((arg1 &&& 0xF) + (arg2 &&& 0xF) + carry &&& 0x10) == 0x10, do: 32, else: 0
  end

  def h_f_8(1, arg1, arg2, carry) do
    if ((arg1 &&& 0xF) - (arg2 &&& 0xF) + carry &&& 0x10) == 0x10, do: 32, else: 0
  end

  # Extract destination and source registers from opcode
  def arit_vals(op, state) do
    src = Bitwise.band(op, 7)
    <<s_val>> = state[src]
    <<dest>> = state[7]
    {dest, s_val}
  end

  # Get address and val of 16 bit register pointer
  def val_16({reg1, reg2}, cpu_state) do
    address = (cpu_state[reg1] <> cpu_state[reg2])
      |> :binary.decode_unsigned()
    val = MMU.read(address)
    {val, address}
  end

  ## Operations
  # nop
  def execute(0x00, state) do
    state
  end

  # ld reg, reg
  def execute(op, state)
      when (op in 0x40..0x6F or op in 0x78..0x7F) and rem(op, 0x10) not in [6, 14] do
    dest =
      Bitwise.>>>(op, 3)
      |> Bitwise.band(7)

    {_dest, s_val} = arit_vals(op, state)

    %{state | dest => <<s_val>>}
  end

  # add reg, reg
  def execute(op, state) when op in 0x80..0x85 or op == 0x87 do
    {dest, s_val} = arit_vals(op, state)
    result = dest + s_val
    z = z_f(<<result>>)
    h = h_f_8(0, dest, s_val)
    c = c_f_8(0, dest, s_val)
    %{state | 7 => <<result>>, 6 => <<z ||| h ||| c>>}
  end

  # adc reg, reg
  def execute(op, state) when op in 0x88..0x8D or op == 0x8F do
    {dest, s_val} = arit_vals(op, state)
    carry = (:binary.decode_unsigned(state[6]) >>> 4) &&& 1
    result = dest + s_val + carry
    z = z_f(<<result>>)
    h = h_f_8(0, dest, s_val, carry)
    c = c_f_8(0, dest, s_val, carry)
    %{state | 7 => <<result>>, 6 => <<z ||| h ||| c>>}
  end

  # sub reg, reg
  def execute(op, state) when op in 0x90..0x95 or op == 0x97 do
    {dest, s_val} = arit_vals(op, state)
    result = dest - s_val
    z = z_f(<<result>>)
    h = h_f_8(1, dest, s_val)
    c = c_f_8(1, dest, s_val)
    %{state | 7 => <<result>>, 6 => <<z ||| 64 ||| h ||| c>>}
  end

  # sbc reg, reg
  def execute(op, state) when op in 0x98..0x9D or op == 0x9F do
    {dest, s_val} = arit_vals(op, state)
    carry = (:binary.decode_unsigned(state[6]) >>> 4) &&& 1
    result = dest - s_val - carry
    z = z_f(<<result>>)
    h = h_f_8(1, dest, s_val, carry)
    c = c_f_8(1, dest, s_val, carry)
    %{state | 7 => <<result>>, 6 => <<z ||| 64 ||| h ||| c>>}
  end

  # and reg, reg
  def execute(op, state) when op in 0xA0..0xA5 or op == 0xA7 do
    {dest, s_val} = arit_vals(op, state)
    result = Bitwise.band(dest, s_val)
    z = z_f(<<result>>)
    %{state | 6 => <<z ||| 32>>, 7 => <<result>>}
  end

  # xor reg, reg
  def execute(op, state) when op in 0xA8..0xAD or op == 0xAF do
    {dest, s_val} = arit_vals(op, state)
    result = Bitwise.bxor(dest, s_val)
    z = z_f(<<result>>)
    %{state | 6 => <<z>>, 7 => <<Bitwise.bxor(dest, s_val)>>}
  end

  # or reg, reg
  def execute(op, state) when op in 0xB0..0xB5 or op == 0xB7 do
    {dest, s_val} = arit_vals(op, state)
    result = Bitwise.bor(dest, s_val)
    z = z_f(<<result>>)
    %{state | 6 => <<z>>, 7 => <<result>>}
  end

  # cp reg, reg
  def execute(op, state) when op in 0xB8..0xBD or op == 0xBF do
    {dest, s_val} = arit_vals(op, state)
    result = dest - s_val
    z = z_f(<<result>>)
    h = h_f_8(1, dest, s_val)
    c = c_f_8(1, dest, s_val)
    %{state | 6 => <<z ||| 64 ||| h ||| c>>}
  end

  # jmp a16
  def execute(0xC3, state) do
    pc =
      MMU.read(state.pc, 2)
      |> :binary.decode_unsigned(:little)

    %{state | pc: pc, cycles: state.cycles + 12}
  end

  # PREFIX CB
  def execute(0xCB, state) do
    MMU.read(state.pc)
    |> Extended.decode(state)
  end

  def execute(op, _cpu_state) do
    raise("Unimplemented Operation #{Integer.to_string(op, 16)}")
  end
end
