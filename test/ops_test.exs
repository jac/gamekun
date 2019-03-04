defmodule GameKunOpsTest do
  use ExUnit.Case
  doctest GameKun.Ops
  alias GameKun.Ops
  alias GameKun.MMU

  @default Application.fetch_env!(:gamekun, :gb_reg)

  setup do
    cart = start_supervised!({GameKun.Cart, "./cpu_instrs.gb"})
    mem = start_supervised!({GameKun.RAM, nil})
    %{cart: cart, mem: mem}
  end

  test "0x00 - nop" do
    assert Ops.decode(<<0x00>>, @default) == %{@default | cycles: 4, pc: 0x101}
  end

  test "0x01 - LD BC, d16" do
    assert Ops.decode(<<0x01>>, @default) == %{@default | 0 => <<0x37>>, 1 => <<0xC3>>, pc: 0x103, cycles: 12}
  end

  test "0x02 - LD (BC), A" do
    assert MMU.read(0xC000) == <<0x00>>
    assert Ops.decode(<<0x02>>, %{@default | 0 => <<0xC0>>, 1 => <<0x00>>}) == %{@default | 0 => <<0xC0>>, 1 => <<0x00>>, pc: 0x101, cycles: 8}
    assert MMU.read(0xC000) == <<0x01>>
  end

  test "0x03 INC BC" do
    assert Ops.decode(<<0x03>>, %{@default | 0 => <<0xC0>>, 1 => <<0x00>>}) == %{@default | 0 => <<0xC0>>, 1 => <<0x01>>, pc: 0x101, cycles: 8}
  end

  test "0x04 INC B" do
    assert Ops.decode(<<0x04>>, @default) == %{@default | 0 => <<0x01>>, 6 => <<16>>, pc: 0x101, cycles: 4}
  end

  test "0x05 DEC B" do
    assert Ops.decode(<<0x05>>, @default) == %{@default | 0 => <<0xFF>>, 6 => <<0x70>>, pc: 0x101, cycles: 4}
  end

  test "0x06 LD B, d8" do
    assert Ops.decode(<<0x06>>, @default) == %{@default | 0 => <<0xC3>>, pc: 0x102, cycles: 8}
  end

  test "0x07 RLC A" do
    assert Ops.decode(<<0x07>>, %{@default | 7 => <<0xFE>>}) == %{@default | 7 => <<0xFD>>, 6 => <<0x10>>, pc: 0x101, cycles: 4}
  end

  test "0x08 LD (a16) SP" do
    assert MMU.read(0xCCDC) == <<0x00>>
    assert MMU.read(0xCCDD) == <<0x00>>
    assert Ops.decode(<<0x08>>, %{@default | pc: 0x11B}) == %{@default | pc: 0x11E, cycles: 20}
    assert MMU.read(0xCCDC) == <<0xFE>>
    assert MMU.read(0xCCDD) == <<0xFF>>
  end

  test "0x09 ADD HL, BC" do
    assert Ops.decode(<<0x09>>, @default) == %{@default | 4 => <<0x01>>, 5 => <<0x60>>, 6=> <<0x80>>, pc: 0x101, cycles: 8}
  end

  test "0x0A LD A, (BC)" do
    assert Ops.decode(<<0x0A>>, @default) == %{@default | 7 => <<0x00>>, pc: 0x101, cycles: 8}
  end

  test "0x0B DEC BC" do
    assert Ops.decode(<<0x0B>>, @default) == %{@default | 1 => <<0x12>>, pc: 0x101, cycles: 8}
  end

  test "0x0C INC C" do
    assert Ops.decode(<<0x0C>>, @default) == %{@default | 1 => <<0x14>>, 6 => <<0x10>>, pc: 0x101, cycles: 4}
  end

  test "0x0D DEC C" do
    assert Ops.decode(<<0x0D>>, %{@default | 6 => <<0>>}) == %{@default | 1 => <<0x12>>, 6 => <<0x40>>, pc: 0x101, cycles: 4}
  end

  test "0x0E LD C, d8" do
    assert Ops.decode(<<0x0E>>, @default) == %{@default | 1 => <<0xC3>>, pc: 0x102, cycles: 8}
  end

  test "0x0F RRC A" do
    assert Ops.decode(<<0x0F>>, %{@default | 7 => <<254>>, 6 => <<64>>}) == %{@default | 7 => <<127>>, 6 => <<0>>, pc: 0x101, cycles: 4}
  end

  test "0x10 - stop" do
    catch_exit Ops.decode(<<0x10>>, @default) == {:shutdown, 0}
  end

  test "0x11 - LD DE, d16" do
    assert Ops.decode(<<0x11>>, @default) == %{@default | 2 => <<0x37>>, 3 => <<0xC3>>, pc: 0x103, cycles: 12}
  end

  test "0x12 - LD (DE), A" do
    assert MMU.read(0xC000) == <<0x00>>
    assert Ops.decode(<<0x12>>, %{@default | 2 => <<0xC0>>, 3 => <<0x00>>}) == %{@default | 2 => <<0xC0>>, 3 => <<0x00>>, pc: 0x101, cycles: 8}
    assert MMU.read(0xC000) == <<0x01>>
  end

  test "0x13 INC DE" do
    assert Ops.decode(<<0x13>>, %{@default | 2 => <<0xC0>>, 3 => <<0x00>>}) == %{@default | 2 => <<0xC0>>, 3 => <<0x01>>, pc: 0x101, cycles: 8}
  end

  test "0x14 INC D" do
    assert Ops.decode(<<0x14>>, @default) == %{@default | 2 => <<0x01>>, 6 => <<0x10>>, pc: 0x101, cycles: 4}
  end

  test "0x15 DEC D" do
    assert Ops.decode(<<0x15>>, %{@default | 6 => <<0>>}) == %{@default | 2 => <<0xFF>>, 6 => <<0x60>>, pc: 0x101, cycles: 4}
  end

  test "0x16 LD D, d8" do
    assert Ops.decode(<<0x16>>, @default) == %{@default | 2 => <<0xC3>>, pc: 0x102, cycles: 8}
  end

  test "0x17 RL A" do
    assert Ops.decode(<<0x17>>, %{@default | 7 => <<0xFE>>, 6 => <<0x10>>}) == %{@default | 7 => <<0xFD>>, 6 => <<0x10>>, pc: 0x101, cycles: 4}
  end

  test "0x18 JR r8" do
    assert Ops.decode(<<0x18>>, @default) == %{@default | pc: 0xC5, cycles: 12}
  end

  test "0x19 ADD HL, DE" do
    assert Ops.decode(<<0x19>>, @default) == %{@default | 4 => <<0x02>>, 5 => <<0x25>>, 6=> <<0x80>>, pc: 0x101, cycles: 8}
  end

  test "0x1A LD A, (DE)" do
    assert Ops.decode(<<0x1A>>, %{@default | 2 => <<0x01>>, 3 => <<0x01>>}) == %{@default | 2 => <<0x01>>, 3 => <<0x01>>, 7 => <<0xC3>>, pc: 0x101, cycles: 8}
  end

  test "0x1B DEC DE" do
    assert Ops.decode(<<0x1B>>, @default) == %{@default | 3 => <<0xD7>>, pc: 0x101, cycles: 8}
  end

  test "0x1C INC E" do
    assert Ops.decode(<<0x1C>>, @default) == %{@default | 3 => <<0xD9>>, 6 => <<0x10>>, pc: 0x101, cycles: 4}
  end

  test "0x1D DEC E" do
    assert Ops.decode(<<0x1D>>, %{@default | 6 => <<0>>}) == %{@default | 3 => <<0xD7>>, 6 => <<0x40>>, pc: 0x101, cycles: 4}
  end

  test "0x1E LD E, d8" do
    assert Ops.decode(<<0x1E>>, @default) == %{@default | 3 => <<0xC3>>, pc: 0x102, cycles: 8}
  end

  test "0x1F RR A" do
    assert Ops.decode(<<0x1F>>, %{@default | 7 => <<1>>, 6 => <<0x10>>}) == %{@default | 7 => <<0x80>>, 6 => <<0x10>>, pc: 0x101, cycles: 4}
  end

  test "0x20 - JR NZ, r8" do
    assert Ops.decode(<<0x20>>, %{@default | 6 => <<0x10>>}) == %{@default | 6 => <<0x10>>, pc: 0xC5, cycles: 12}
  end

  test "0x21 - LD HL, d16" do
    assert Ops.decode(<<0x21>>, @default) == %{@default | 4 => <<0x37>>, 5 => <<0xC3>>, pc: 0x103, cycles: 12}
  end

  test "0x22 - LD (HL+), A" do
    assert MMU.read(0xC000) == <<0x00>>
    assert Ops.decode(<<0x22>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@default | 4 => <<0xC0>>, 5 => <<0x01>>, pc: 0x101, cycles: 8}
    assert MMU.read(0xC000) == <<0x01>>
  end

  test "0x23 INC HL" do
    assert Ops.decode(<<0x23>>, @default) == %{@default | 5 => <<0x4E>>, pc: 0x101, cycles: 8}
  end

  test "0x24 INC H" do
    assert Ops.decode(<<0x24>>, @default) == %{@default | 4 => <<0x02>>, 6 => <<0x10>>, pc: 0x101, cycles: 4}
  end

  test "0x25 DEC H" do
    assert Ops.decode(<<0x25>>, %{@default | 6 => <<0>>}) == %{@default | 4 => <<0x00>>, 6 => <<0xC0>>, pc: 0x101, cycles: 4}
  end

  test "0x26 LD H, d8" do
    assert Ops.decode(<<0x26>>, @default) == %{@default | 4 => <<0xC3>>, pc: 0x102, cycles: 8}
  end

  test "0x27 DAA" do
    assert Ops.decode(<<0x27>>, %{@default | 7 => <<0x6D>>}) == %{@default | 7 => <<0x73>>, 6 => <<0>>, pc: 0x101, cycles: 4}
  end

  test "0x28 JR Z, r8" do
    assert Ops.decode(<<0x28>>, %{@default | 6 => <<0x80>>}) == %{@default | 6 => <<0x80>>, pc: 0xC5, cycles: 12}
  end

  test "0x29 ADD HL, HL" do
    assert Ops.decode(<<0x29>>, @default) == %{@default | 4 => <<0x02>>, 5 => <<0x9A>>, 6 => <<0x80>>, pc: 0x101, cycles: 8}
  end

  test "0x2A LD A, (HL+)" do
    assert Ops.decode(<<0x2A>>, %{@default | 4 => <<0x02>>, 5 => <<0x49>>}) == %{@default | 4 => <<0x02>>, 5 => <<0x4A>>, 7 => <<0xC9>>, pc: 0x101, cycles: 8}
  end

  test "0x2B DEC HL" do
    assert Ops.decode(<<0x2B>>, @default) == %{@default | 5 => <<0x4C>>, pc: 0x101, cycles: 8}
  end

  test "0x2C INC L" do
    assert Ops.decode(<<0x2C>>, @default) == %{@default | 5 => <<0x4E>>, 6 => <<0x10>>, pc: 0x101, cycles: 4}
  end

  test "0x2D DEC L" do
    assert Ops.decode(<<0x2D>>, %{@default | 6 => <<0>>}) == %{@default | 5 => <<0x4C>>, 6 => <<0x40>>, pc: 0x101, cycles: 4}
  end

  test "0x2E LD L, d8" do
    assert Ops.decode(<<0x2E>>, @default) == %{@default | 5 => <<0xC3>>, pc: 0x102, cycles: 8}
  end

  test "0x2F CPL A" do
    assert Ops.decode(<<0x2F>>, %{@default | 7 => <<0x50>>}) == %{@default | 7 => <<0xAF>>, 6 => <<0xF0>>, pc: 0x101, cycles: 4}
  end

  test "0x30 - JR NZ, r8" do
    assert Ops.decode(<<0x30>>, %{@default | 6 => <<0x80>>}) == %{@default | 6 => <<0x80>>, pc: 0xC5, cycles: 12}
  end

  test "0x31 - LD SP, d16" do
    assert Ops.decode(<<0x31>>, @default) == %{@default | sp: 0x37C3, pc: 0x103, cycles: 12}
  end

  test "0x32 - LD (HL-), A" do
    assert MMU.read(0xC000) == <<0x00>>
    assert Ops.decode(<<0x32>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@default | 4 => <<0xBF>>, 5 => <<0xFF>>, pc: 0x101, cycles: 8}
    assert MMU.read(0xC000) == <<0x01>>
  end

  test "0x33 INC SP" do
    assert Ops.decode(<<0x33>>, @default) == %{@default | sp: 0xFFFF, pc: 0x101, cycles: 8}
  end

  test "0x34 INC (HL)" do
    assert MMU.read(0xC000) == <<0x00>>
    MMU.write(0xC000, <<0xFF>>)
    assert Ops.decode(<<0x34>>, %{@default | 4 => <<0xC0>>, 5 => <<0>>}) == %{@default | 4 => <<0xC0>>, 5 => <<0>>, 6 => <<0xB0>>, pc: 0x101, cycles: 12}
    assert MMU.read(0xC000) == <<0x00>>
  end

  test "0x35 DEC (HL)" do
    assert MMU.read(0xC000) == <<0x00>>
    assert Ops.decode(<<0x35>>, %{@default | 4 => <<0xC0>>, 5 => <<0>>}) == %{@default | 4 => <<0xC0>>, 5 => <<0>>, 6 => <<0x70>>, pc: 0x101, cycles: 12}
    assert MMU.read(0xC000) == <<0xFF>>
  end

  test "0x36 LD (HL) d8" do
    assert MMU.read(0xC000) == <<0x00>>
    assert Ops.decode(<<0x36>>, %{@default | 4 => <<0xC0>>, 5 => <<0>>}) == %{@default | 4 => <<0xC0>>, 5 => <<0>>, pc: 0x102, cycles: 12}
    assert MMU.read(0xC000) == <<0xC3>>
  end

  test "0x37 SCF" do
    assert Ops.decode(<<0x37>>, %{@default | 6 => <<0>>}) == %{@default | 6 => <<0x10>>, pc: 0x101, cycles: 4}
  end

  test "0x38 JR C, r8" do
    assert Ops.decode(<<0x38>>, @default) == %{@default | pc: 0xC5, cycles: 12}
  end

  test "0x39 ADD, HL, SP" do
    assert Ops.decode(<<0x39>>, @default) == %{@default | 5 => <<0x4B>>, 6 => <<0xB0>>, pc: 0x101, cycles: 8}
  end

  test "0x3A LD A, (HL-)" do
    assert Ops.decode(<<0x3A>>, %{@default | 4 => <<0x02>>, 5 => <<0x49>>}) == %{@default | 4 => <<0x02>>, 5 => <<0x48>>, 7 => <<0xC9>>, pc: 0x101, cycles: 8}
  end

  test "0x3B DEC SP" do
    assert Ops.decode(<<0x3B>>, @default) == %{@default | sp: 0xFFFD, pc: 0x101, cycles: 8}
  end

  test "0x3C INC A" do
    assert Ops.decode(<<0x3C>>, @default) == %{@default | 7 => <<0x02>>, 6 => <<16>>, pc: 0x101, cycles: 4}
  end

  test "0x3D DEC A" do
    assert Ops.decode(<<0x3D>>, %{@default | 6 => <<0>>}) == %{@default | 7 => <<0x00>>, 6 => <<0xC0>>, pc: 0x101, cycles: 4}
  end

  test "0x3E LD A, d8" do
    assert Ops.decode(<<0x3E>>, @default) == %{@default | 7 => <<0xC3>>, pc: 0x102, cycles: 8}
  end

  test "0x3F CCF" do
    assert Ops.decode(<<0x3F>>, %{@default | 6 => <<0xF0>>}) == %{@default | 6 => <<0x80>>, pc: 0x101, cycles: 4}
  end

  test "0x40.. - LD B, reg//(HL)" do
    assert Ops.decode(<<0x40>>, %{@default | 0 => <<5>>}) == %{@default | 0 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x41>>, %{@default | 1 => <<5>>}) == %{@default | 0 => <<5>>, 1 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x42>>, %{@default | 2 => <<5>>}) == %{@default | 0 => <<5>>, 2 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x43>>, %{@default | 3 => <<5>>}) == %{@default | 0 => <<5>>, 3 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x44>>, %{@default | 4 => <<5>>}) == %{@default | 0 => <<5>>, 4 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x45>>, %{@default | 5 => <<5>>}) == %{@default | 0 => <<5>>, 5 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x46>>, %{@default | 4 => <<0xC0>>}) == %{@default | 4 => <<0xC0>>, 0 => <<0>>, pc: 0x101, cycles: 8}
    assert Ops.decode(<<0x47>>, %{@default | 7 => <<5>>}) == %{@default | 0 => <<5>>, 7 => <<5>>, pc: 0x101, cycles: 4}
  end

  test "0x48.. - LD C, reg//(HL)" do
    assert Ops.decode(<<0x48>>, %{@default | 0 => <<5>>}) == %{@default | 1 => <<5>>, 0 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x49>>, %{@default | 1 => <<5>>}) == %{@default | 1 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x4A>>, %{@default | 2 => <<5>>}) == %{@default | 1 => <<5>>, 2 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x4B>>, %{@default | 3 => <<5>>}) == %{@default | 1 => <<5>>, 3 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x4C>>, %{@default | 4 => <<5>>}) == %{@default | 1 => <<5>>, 4 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x4D>>, %{@default | 5 => <<5>>}) == %{@default | 1 => <<5>>, 5 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x4E>>, %{@default | 4 => <<0xC0>>}) == %{@default | 4 => <<0xC0>>, 1 => <<0>>, pc: 0x101, cycles: 8}
    assert Ops.decode(<<0x4F>>, %{@default | 7 => <<5>>}) == %{@default | 1 => <<5>>, 7 => <<5>>, pc: 0x101, cycles: 4}
  end

  test "0x50.. - LD D, reg//(HL)" do
    assert Ops.decode(<<0x50>>, %{@default | 0 => <<5>>}) == %{@default | 2 => <<5>>, 0 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x51>>, %{@default | 1 => <<5>>}) == %{@default | 2 => <<5>>, 1 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x52>>, %{@default | 2 => <<5>>}) == %{@default | 2 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x53>>, %{@default | 3 => <<5>>}) == %{@default | 2 => <<5>>, 3 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x54>>, %{@default | 4 => <<5>>}) == %{@default | 2 => <<5>>, 4 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x55>>, %{@default | 5 => <<5>>}) == %{@default | 2 => <<5>>, 5 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x56>>, %{@default | 4 => <<0xC0>>}) == %{@default | 4 => <<0xC0>>, 2 => <<0>>, pc: 0x101, cycles: 8}
    assert Ops.decode(<<0x57>>, %{@default | 7 => <<5>>}) == %{@default | 2 => <<5>>, 7 => <<5>>, pc: 0x101, cycles: 4}
  end

  test "0x58.. - LD E, reg//(HL)" do
    assert Ops.decode(<<0x58>>, %{@default | 0 => <<5>>}) == %{@default | 3 => <<5>>, 0 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x59>>, %{@default | 1 => <<5>>}) == %{@default | 3 => <<5>>, 1 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x5A>>, %{@default | 2 => <<5>>}) == %{@default | 3 => <<5>>, 2 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x5B>>, %{@default | 3 => <<5>>}) == %{@default | 3 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x5C>>, %{@default | 4 => <<5>>}) == %{@default | 3 => <<5>>, 4 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x5D>>, %{@default | 5 => <<5>>}) == %{@default | 3 => <<5>>, 5 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x5E>>, %{@default | 4 => <<0xC0>>}) == %{@default | 4 => <<0xC0>>, 3 => <<0>>, pc: 0x101, cycles: 8}
    assert Ops.decode(<<0x5F>>, %{@default | 7 => <<5>>}) == %{@default | 3 => <<5>>, 7 => <<5>>, pc: 0x101, cycles: 4}
  end

  test "0x60.. - LD H, reg//(HL)" do
    assert Ops.decode(<<0x60>>, %{@default | 0 => <<5>>}) == %{@default | 4 => <<5>>, 0 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x61>>, %{@default | 1 => <<5>>}) == %{@default | 4 => <<5>>, 1 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x62>>, %{@default | 2 => <<5>>}) == %{@default | 4 => <<5>>, 2 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x63>>, %{@default | 3 => <<5>>}) == %{@default | 4 => <<5>>, 3 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x64>>, %{@default | 4 => <<5>>}) == %{@default | 4 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x65>>, %{@default | 5 => <<5>>}) == %{@default | 4 => <<5>>, 5 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x66>>, %{@default | 4 => <<0xC0>>}) == %{@default | 4 => <<0>>, pc: 0x101, cycles: 8}
    assert Ops.decode(<<0x67>>, %{@default | 7 => <<5>>}) == %{@default | 4 => <<5>>, 7 => <<5>>, pc: 0x101, cycles: 4}
  end

  test "0x68.. - LD L, reg//(HL)" do
    assert Ops.decode(<<0x68>>, %{@default | 0 => <<5>>}) == %{@default | 5 => <<5>>, 0 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x69>>, %{@default | 1 => <<5>>}) == %{@default | 5 => <<5>>, 1 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x6A>>, %{@default | 2 => <<5>>}) == %{@default | 5 => <<5>>, 2 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x6B>>, %{@default | 3 => <<5>>}) == %{@default | 5 => <<5>>, 3 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x6C>>, %{@default | 4 => <<5>>}) == %{@default | 5 => <<5>>, 4 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x6D>>, %{@default | 5 => <<5>>}) == %{@default | 5 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x6E>>, %{@default | 4 => <<0xC0>>}) == %{@default | 4 => <<0xC0>>, 5 => <<0>>, pc: 0x101, cycles: 8}
    assert Ops.decode(<<0x6F>>, %{@default | 7 => <<5>>}) == %{@default | 5 => <<5>>, 7 => <<5>>, pc: 0x101, cycles: 4}
  end

  test "0x70.. - LD (HL), reg" do
    assert MMU.read(0xC04D) == <<0>>
    assert Ops.decode(<<0x70>>, %{@default | 0 => <<1>>, 4 => <<0xC0>>}) == %{@default | 0 => <<1>>, 4 => <<0xC0>>, pc: 0x101, cycles: 8}
    assert MMU.read(0xC04D) == <<1>>
    assert Ops.decode(<<0x71>>, %{@default | 1 => <<2>>, 4 => <<0xC0>>}) == %{@default | 1 => <<2>>, 4 => <<0xC0>>, pc: 0x101, cycles: 8}
    assert MMU.read(0xC04D) == <<2>>
    assert Ops.decode(<<0x72>>, %{@default | 2 => <<3>>, 4 => <<0xC0>>}) == %{@default | 2 => <<3>>, 4 => <<0xC0>>, pc: 0x101, cycles: 8}
    assert MMU.read(0xC04D) == <<3>>
    assert Ops.decode(<<0x73>>, %{@default | 3 => <<4>>, 4 => <<0xC0>>}) == %{@default | 3 => <<4>>, 4 => <<0xC0>>, pc: 0x101, cycles: 8}
    assert MMU.read(0xC04D) == <<4>>
    assert Ops.decode(<<0x74>>, %{@default | 4 => <<0xC0>>}) == %{@default | 4 => <<0xC0>>, pc: 0x101, cycles: 8}
    assert MMU.read(0xC04D) == <<0xC0>>
    assert Ops.decode(<<0x75>>, %{@default | 5 => <<0x4D>>, 4 => <<0xC0>>}) == %{@default | 4 => <<0xC0>>, 5 => <<0x4D>>, pc: 0x101, cycles: 8}
    assert MMU.read(0xC04D) == <<0x4D>>
    assert Ops.decode(<<0x77>>, %{@default | 7 => <<7>>, 4 => <<0xC0>>}) == %{@default | 7 => <<7>>, 4 => <<0xC0>>, pc: 0x101, cycles: 8}
    assert MMU.read(0xC04D) == <<7>>
  end

  # Can't Test without starting CPU
  # test "0x76 - HALT" do
  #   assert Ops.decode(<<0x76>>, @default) == @default
  # end

  test "0x78.. - LD A, reg//(HL)" do
    assert Ops.decode(<<0x78>>, %{@default | 0 => <<5>>}) == %{@default | 7 => <<5>>, 0 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x79>>, %{@default | 1 => <<5>>}) == %{@default | 7 => <<5>>, 1 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x7A>>, %{@default | 2 => <<5>>}) == %{@default | 7 => <<5>>, 2 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x7B>>, %{@default | 3 => <<5>>}) == %{@default | 7 => <<5>>, 3 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x7C>>, %{@default | 4 => <<5>>}) == %{@default | 7 => <<5>>, 4 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x7D>>, %{@default | 5 => <<5>>}) == %{@default | 7 => <<5>>, 5 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x7E>>, %{@default | 4 => <<0xC0>>}) == %{@default | 4 => <<0xC0>>, 7 => <<0>>, pc: 0x101, cycles: 8}
    assert Ops.decode(<<0x7F>>, %{@default | 7 => <<5>>}) == %{@default | 7 => <<5>>, pc: 0x101, cycles: 4}
  end

  test "0x80.. - ADD A, reg//(HL)" do
    assert Ops.decode(<<0x80>>, %{@default | 0 => <<15>>}) == %{@default | 7 => <<16>>, 0 => <<15>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x81>>, %{@default | 1 => <<5>>}) == %{@default | 7 => <<6>>, 1 => <<5>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x82>>, %{@default | 2 => <<255>>}) == %{@default | 7 => <<0>>, 2 => <<255>>, 6 => <<176>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x83>>, %{@default | 3 => <<5>>}) == %{@default | 7 => <<6>>, 3 => <<5>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x84>>, %{@default | 4 => <<5>>}) == %{@default | 7 => <<6>>, 4 => <<5>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x85>>, %{@default | 5 => <<5>>}) == %{@default | 7 => <<6>>, 5 => <<5>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x86>>, @default) == %{@default | 6 => <<0>>, 7 => <<0x3C>>, pc: 0x101, cycles: 8}
    assert Ops.decode(<<0x87>>, %{@default | 7 => <<5>>}) == %{@default | 7 => <<10>>, 6 => <<0>>, pc: 0x101, cycles: 4}
  end

  test "0x88.. - ADC A, reg//(HL)" do
    assert Ops.decode(<<0x88>>, %{@default | 0 => <<15>>, 6 => <<128>>}) == %{@default | 7 => <<16>>, 0 => <<15>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x89>>, %{@default | 1 => <<5>>, 6 => <<64>>}) == %{@default | 7 => <<6>>, 1 => <<5>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x8A>>, %{@default | 2 => <<255>>, 6 => <<32>>}) == %{@default | 7 => <<0>>, 2 => <<255>>, 6 => <<176>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x8B>>, %{@default | 3 => <<255>>, 6 => <<16>>}) == %{@default | 7 => <<1>>, 3 => <<255>>, 6 => <<48>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x8C>>, %{@default | 4 => <<5>>, 6 => <<16>>}) == %{@default | 7 => <<7>>, 4 => <<5>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x8D>>, %{@default | 5 => <<5>>, 6 => <<0>>}) == %{@default | 7 => <<6>>, 5 => <<5>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x8E>>, @default) == %{@default | 6 => <<0x00>>, 7 => <<0x3D>>, pc: 0x101, cycles: 8}
    assert Ops.decode(<<0x8F>>, %{@default | 7 => <<129>>, 6 => <<16>>}) == %{@default | 7 => <<3>>, 6 => <<16>>, pc: 0x101, cycles: 4}
  end

  test "0x90.. - SUB A, reg//(HL)" do
    assert Ops.decode(<<0x90>>, %{@default | 0 => <<1>>}) == %{@default | 7 => <<0>>, 0 => <<1>>, 6 => <<0xC0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x91>>, %{@default | 1 => <<0>>}) == %{@default | 7 => <<1>>, 1 => <<0>>, 6 => <<0x40>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x92>>, %{@default | 2 => <<3>>, 7 => <<2>>}) == %{@default | 7 => <<255>>, 2 => <<3>>, 6 => <<0x70>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x93>>, %{@default | 3 => <<2>>, 7 => <<128>>}) == %{@default | 7 => <<126>>, 3 => <<2>>, 6 => <<0x60>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x94>>, %{@default | 4 => <<2>>, 7 => <<200>>}) == %{@default | 7 => <<198>>, 4 => <<2>>, 6 => <<0x40>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x95>>, %{@default | 5 => <<8>>, 7 => <<100>>}) == %{@default | 7 => <<92>>, 5 => <<8>>, 6 => <<0x60>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x96>>, %{@default | 7 => <<0x3B>>}) == %{@default | 6 => <<0xC0>>, 7 => <<0>>, pc: 0x101, cycles: 8}
    assert Ops.decode(<<0x97>>, %{@default | 7 => <<7>>}) == %{@default | 7 => <<0>>, 6 => <<0xC0>>, pc: 0x101, cycles: 4}
  end

  test "0x98.. - SBC A, reg//(HL)" do
    assert Ops.decode(<<0x98>>, %{@default | 0 => <<1>>, 6 => <<0>>}) == %{@default | 7 => <<0>>, 0 => <<1>>, 6 => <<0xC0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x99>>, %{@default | 1 => <<2>>, 6 => <<0x10>>}) == %{@default | 7 => <<254>>, 1 => <<2>>, 6 => <<0x70>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x9A>>, %{@default | 2 => <<3>>, 7 => <<3>>, 6 => <<0x10>>}) == %{@default | 7 => <<255>>, 2 => <<3>>, 6 => <<0x70>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x9B>>, %{@default | 3 => <<2>>, 7 => <<128>>, 6 => <<0x10>>}) == %{@default | 7 => <<125>>, 3 => <<2>>, 6 => <<0x60>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x9C>>, %{@default | 4 => <<1>>, 7 => <<127>>, 6 => <<0x10>>}) == %{@default | 7 => <<125>>, 4 => <<1>>, 6 => <<0x40>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x9D>>, %{@default | 5 => <<8>>, 7 => <<100>>, 6 => <<0>>}) == %{@default | 7 => <<92>>, 5 => <<8>>, 6 => <<0x60>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x9E>>, %{@default | 7 => <<0x3B>>}) == %{@default | 6 => <<0x70>>, 7 => <<0xFF>>, pc: 0x101, cycles: 8}
    assert Ops.decode(<<0x9F>>, %{@default | 7 => <<8>>, 6 => <<16>>}) == %{@default | 7 => <<255>>, 6 => <<0x70>>, pc: 0x101, cycles: 4}
  end

  test "0xA0.. - AND A, reg//(HL)" do
    assert Ops.decode(<<0xA0>>, %{@default | 0 => <<1>>}) == %{@default | 6 => <<0x20>>, 7 => <<1>>, 0 => <<1>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xA1>>, %{@default | 1 => <<2>>}) == %{@default | 6 => <<160>>, 7 => <<0>>, 1 => <<2>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xA2>>, %{@default | 2 => <<3>>}) == %{@default | 6 => <<0x20>>, 7 => <<1>>, 2 => <<3>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xA3>>, %{@default | 3 => <<4>>}) == %{@default | 6 => <<160>>, 7 => <<0>>, 3 => <<4>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xA4>>, %{@default | 4 => <<5>>}) == %{@default | 6 => <<0x20>>, 7 => <<1>>, 4 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xA5>>, %{@default | 5 => <<6>>}) == %{@default | 6 => <<160>>, 7 => <<0>>, 5 => <<6>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xA6>>, %{@default | 7 => <<3>>}) == %{@default | 6 => <<0x20>>, 7 => <<3>>, pc: 0x101, cycles: 8}
    assert Ops.decode(<<0xA7>>, %{@default | 7 => <<7>>}) == %{@default | 6 => <<0x20>>, 7 => <<7>>, pc: 0x101, cycles: 4}
  end

  test "0xA8.. - XOR A, reg//(HL)" do
    assert Ops.decode(<<0xA8>>, %{@default | 0 => <<1>>}) == %{@default | 7 => <<0>>, 0 => <<1>>, 6 => <<128>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xA9>>, %{@default | 1 => <<2>>}) == %{@default | 7 => <<3>>, 1 => <<2>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xAA>>, %{@default | 2 => <<3>>}) == %{@default | 7 => <<2>>, 2 => <<3>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xAB>>, %{@default | 3 => <<4>>}) == %{@default | 7 => <<5>>, 3 => <<4>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xAC>>, %{@default | 4 => <<5>>}) == %{@default | 7 => <<4>>, 4 => <<5>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xAD>>, %{@default | 5 => <<6>>}) == %{@default | 7 => <<7>>, 5 => <<6>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xAE>>, %{@default | 7 => <<3>>}) == %{@default | 6 => <<0x00>>, 7 => <<0x38>>, pc: 0x101, cycles: 8}
    assert Ops.decode(<<0xAF>>, %{@default | 7 => <<7>>}) == %{@default | 7 => <<0>>, 6 => <<128>>, pc: 0x101, cycles: 4}
  end

  test "0xB0.. - OR A, reg//(HL)" do
    assert Ops.decode(<<0xB0>>, %{@default | 0 => <<1>>}) == %{@default | 7 => <<1>>, 0 => <<1>>,6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xB1>>, %{@default | 1 => <<2>>}) == %{@default | 7 => <<3>>, 1 => <<2>>,6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xB2>>, %{@default | 2 => <<3>>}) == %{@default | 7 => <<3>>, 2 => <<3>>,6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xB3>>, %{@default | 3 => <<4>>}) == %{@default | 7 => <<5>>, 3 => <<4>>,6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xB4>>, %{@default | 4 => <<5>>}) == %{@default | 7 => <<5>>, 4 => <<5>>,6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xB5>>, %{@default | 5 => <<6>>}) == %{@default | 7 => <<7>>, 5 => <<6>>,6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xB6>>, %{@default | 7 => <<3>>}) == %{@default | 6 => <<0x00>>, 7 => <<0x3B>>, pc: 0x101, cycles: 8}
    assert Ops.decode(<<0xB7>>, %{@default | 7 => <<0>>}) == %{@default | 7 => <<0>>, 6 => <<128>>, pc: 0x101, cycles: 4}
  end

  test "0xB8.. - CP A, reg//(HL)" do
    assert Ops.decode(<<0xB8>>, %{@default | 0 => <<1>>, 6 => <<0>>}) == %{@default | 0 => <<1>>, 6 => <<0xC0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xB9>>, %{@default | 1 => <<0>>, 6 => <<0>>}) == %{@default | 1 => <<0>>, 6 => <<0x40>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xBA>>, %{@default | 2 => <<3>>, 6 => <<16>>}) == %{@default | 2 => <<3>>, 6 => <<0x70>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xBB>>, %{@default | 3 => <<2>>, 7 => <<2>>, 6 => <<16>>}) == %{@default | 7 => <<2>>, 3 => <<2>>, 6 => <<0xC0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xBC>>, %{@default | 4 => <<2>>, 7 => <<200>>, 6 => <<0>>}) == %{@default | 7 => <<200>>, 4 => <<2>>, 6 => <<0x40>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xBD>>, %{@default | 5 => <<8>>, 7 => <<100>>, 6 => <<0>>}) == %{@default | 7 => <<100>>, 5 => <<8>>, 6 => <<0x60>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xBE>>, %{@default | 7 => <<0x3B>>}) == %{@default | 6 => <<0xC0>>, 7 => <<0x3B>>, pc: 0x101, cycles: 8}
    assert Ops.decode(<<0xBF>>, %{@default | 7 => <<7>>, 6 => <<0>>}) == %{@default | 7 => <<7>>, 6 => <<0xC0>>, pc: 0x101, cycles: 4}
  end

  test "0xC0 - RET NZ" do
    MMU.write(0xFFFD, <<0x12>>)
    MMU.write(0xFFFC, <<0x34>>)
    assert Ops.decode(<<0xC0>>, %{@default | 6 => <<0x10>>, sp: 0xFFFC}) == %{@default | 6 => <<0x10>>, pc: 0x1234, sp: 0xFFFE, cycles: 20}
  end

  test "0xC1 - POP BC" do
    MMU.write(0xFFFD, <<0x12>>)
    MMU.write(0xFFFC, <<0x34>>)
    assert Ops.decode(<<0xC1>>, %{@default | sp: 0xFFFC}) == %{@default | 0 => <<0x12>>, 1 => <<0x34>>, sp: 0xFFFE, pc: 0x101, cycles: 12}
  end

  test "0xC2 - JMP NZ, a16" do
    assert Ops.decode(<<0xC2>>, %{@default | 6 => <<0x10>>, pc: 0x101}) == %{@default | 6 => <<0x10>>, pc: 0x0637, cycles: 16}
  end

  test "0xC3 - JMP a16" do
    assert Ops.decode(<<0xC3>>, %{@default | pc: 0x101}) == %{@default | pc: 0x0637, cycles: 16}
  end

  test "0xC4 -  CALL NZ, a16" do
    assert Ops.decode(<<0xC4>>, %{@default | 6 => <<0x10>>, pc: 0x101}) == %{@default | 6 => <<0x10>>, sp: 0xFFFC, pc: 0x0637, cycles: 24}
    assert MMU.read(0xFFFD) == <<0x01>>
    assert MMU.read(0xFFFC) == <<0x04>>
  end

  test " 0xC5 PUSH BC" do
    assert Ops.decode(<<0xC5>>, @default) == %{@default | pc: 0x101, sp: 0xFFFC, cycles: 16}
    assert MMU.read(0xFFFD) == <<0x00>>
    assert MMU.read(0xFFFC) == <<0x13>>
  end

  test "0xC6 - ADD A, D8" do
    assert Ops.decode(<<0xC6>>, @default) == %{@default | 6 => <<0>>, 7 => <<0xC4>>, pc: 0x102, cycles: 8}
  end

  test "0xC7 - RST 00" do
    assert Ops.decode(<<0xC7>>, %{@default | pc: 0x1233}) == %{@default | pc: 0x00, sp: 0xFFFC, cycles: 16}
    assert MMU.read(0xFFFD) == <<0x12>>
    assert MMU.read(0xFFFC) == <<0x34>> # decode adds 1
  end

  test "0xC8 - RET Z" do
    MMU.write(0xFFFD, <<0x12>>)
    MMU.write(0xFFFC, <<0x34>>)
    assert Ops.decode(<<0xC8>>, %{@default | 6 => <<0x80>>, sp: 0xFFFC}) == %{@default | 6 => <<0x80>>, pc: 0x1234, sp: 0xFFFE, cycles: 20}
  end

  test "0xC9 - RET" do
    MMU.write(0xFFFD, <<0x12>>)
    MMU.write(0xFFFC, <<0x34>>)
    assert Ops.decode(<<0xC9>>, %{@default | sp: 0xFFFC}) == %{@default | pc: 0x1234, sp: 0xFFFE, cycles: 16}
  end

  test "0xCA - JMP Z, a16" do
    assert Ops.decode(<<0xCA>>, %{@default | 6 => <<0x80>>, pc: 0x101}) == %{@default | 6 => <<0x80>>, pc: 0x0637, cycles: 16}
  end

  test "0xCB - prefix" do
    assert Ops.decode(<<0xCB>>, %{@default | pc: 0x101}) == %{@default | 7 => <<0x10>>, 6 => <<0x00>>, pc: 0x103, cycles: 8}
  end

  test "0xCC -  CALL Z, a16" do
    assert Ops.decode(<<0xCC>>, %{@default | 6 => <<0x80>>, pc: 0x101}) == %{@default | 6 => <<0x80>>, sp: 0xFFFC, pc: 0x0637, cycles: 24}
    assert MMU.read(0xFFFD) == <<0x01>>
    assert MMU.read(0xFFFC) == <<0x04>>
  end

  test "0xCD -  CALL NZ, a16" do
    assert Ops.decode(<<0xCD>>, %{@default | pc: 0x101}) == %{@default | sp: 0xFFFC, pc: 0x0637, cycles: 24}
    assert MMU.read(0xFFFD) == <<0x01>>
    assert MMU.read(0xFFFC) == <<0x04>>
  end

  test "0xCE - ADC A, D8" do
    assert Ops.decode(<<0xCE>>, @default) == %{@default | 6 => <<0>>, 7 => <<0xC5>>, pc: 0x102, cycles: 8}
  end

  test "0xCF - RST 08" do
    assert Ops.decode(<<0xCF>>, %{@default | pc: 0x1233}) == %{@default | pc: 0x08, sp: 0xFFFC, cycles: 16}
    assert MMU.read(0xFFFD) == <<0x12>>
    assert MMU.read(0xFFFC) == <<0x34>> # decode adds 1
  end

  test "0xD0 - RET NC" do
    MMU.write(0xFFFD, <<0x12>>)
    MMU.write(0xFFFC, <<0x34>>)
    assert Ops.decode(<<0xD0>>, %{@default | 6 => <<0x20>>, sp: 0xFFFC}) == %{@default | 6 => <<0x20>>, pc: 0x1234, sp: 0xFFFE, cycles: 20}
  end

  test "0xD1 - POP DE" do
    MMU.write(0xFFFD, <<0x12>>)
    MMU.write(0xFFFC, <<0x34>>)
    assert Ops.decode(<<0xD1>>, %{@default | sp: 0xFFFC}) == %{@default | 2 => <<0x12>>, 3 => <<0x34>>, sp: 0xFFFE, pc: 0x101, cycles: 12}
  end

  test "0xD2 - JMP NC, a16" do
    assert Ops.decode(<<0xD2>>, %{@default | 6 => <<0x80>>, pc: 0x101}) == %{@default | 6 => <<0x80>>, pc: 0x0637, cycles: 16}
  end

  test "0xD4 -  CALL NC, a16" do
    assert Ops.decode(<<0xD4>>, %{@default | 6 => <<0x80>>, pc: 0x101}) == %{@default | 6 => <<0x80>>, sp: 0xFFFC, pc: 0x0637, cycles: 24}
    assert MMU.read(0xFFFD) == <<0x01>>
    assert MMU.read(0xFFFC) == <<0x04>>
  end

  test " 0xD5 PUSH DE" do
    assert Ops.decode(<<0xD5>>, @default) == %{@default | pc: 0x101, sp: 0xFFFC, cycles: 16}
    assert MMU.read(0xFFFD) == <<0x00>>
    assert MMU.read(0xFFFC) == <<0xD8>>
  end

  test "0xD6 - SUB A, D8" do
    assert Ops.decode(<<0xD6>>, @default) == %{@default | 6 => <<0x70>>, 7 => <<0x3E>>, pc: 0x102, cycles: 8}
  end

  test "0xD7 - RST 10" do
    assert Ops.decode(<<0xD7>>, %{@default | pc: 0x1233}) == %{@default | pc: 0x10, sp: 0xFFFC, cycles: 16}
    assert MMU.read(0xFFFD) == <<0x12>>
    assert MMU.read(0xFFFC) == <<0x34>> # decode adds 1
  end

  test "0xD8 - RET C" do
    MMU.write(0xFFFD, <<0x12>>)
    MMU.write(0xFFFC, <<0x34>>)
    assert Ops.decode(<<0xD8>>, %{@default | 6 => <<0x10>>, sp: 0xFFFC}) == %{@default | 6 => <<0x10>>, pc: 0x1234, sp: 0xFFFE, cycles: 20}
  end

  test "0xD9 - RETI" do
    MMU.write(0xFFFD, <<0x12>>)
    MMU.write(0xFFFC, <<0x34>>)
    assert Ops.decode(<<0xD9>>, %{@default | sp: 0xFFFC}) == %{@default | pc: 0x1234, sp: 0xFFFE, ime: 1, cycles: 16}
  end

  test "0xDA - JMP C, a16" do
    assert Ops.decode(<<0xC2>>, %{@default | 6 => <<0x10>>, pc: 0x101}) == %{@default | 6 => <<0x10>>, pc: 0x0637, cycles: 16}
  end

  test "0xDC -  CALL C, a16" do
    assert Ops.decode(<<0xDC>>, %{@default | 6 => <<0x10>>, pc: 0x101}) == %{@default | 6 => <<0x10>>, sp: 0xFFFC, pc: 0x0637, cycles: 24}
    assert MMU.read(0xFFFD) == <<0x01>>
    assert MMU.read(0xFFFC) == <<0x04>>
  end

  test "0xDE - SBC A, D8" do
    assert Ops.decode(<<0xDE>>, @default) ==  %{@default | 6 => <<0x70>>, 7 => <<0x3D>>, pc: 0x102, cycles: 8}
  end

  test "0xDF - RST 18" do
    assert Ops.decode(<<0xDF>>, %{@default | pc: 0x1233}) == %{@default | pc: 0x18, sp: 0xFFFC, cycles: 16}
    assert MMU.read(0xFFFD) == <<0x12>>
    assert MMU.read(0xFFFC) == <<0x34>> # decode adds 1
  end

  test "0xE0 - LDH (a8), A" do
    assert MMU.read(0xFFC3) == <<0x00>>
    assert Ops.decode(<<0xE0>>, %{@default | pc: 0x100}) == %{@default | pc: 0x102, cycles: 12}
    assert MMU.read(0xFFC3) == <<0x01>>
  end

  test "0xE1 - POP HL" do
    MMU.write(0xFFFD, <<0x12>>)
    MMU.write(0xFFFC, <<0x34>>)
    assert Ops.decode(<<0xE1>>, %{@default | sp: 0xFFFC}) == %{@default | 4 => <<0x12>>, 5 => <<0x34>>, sp: 0xFFFE, pc: 0x101, cycles: 12}
  end

  test "0xE2 - LDH (C), A" do
    assert Ops.decode(<<0xE2>>, @default) == %{@default | pc: 0x101, cycles: 8}
    assert MMU.read(0xFF13) == <<0x01>>
  end

  test "0xE5 PUSH HL" do
    assert Ops.decode(<<0xE5>>, @default) == %{@default | pc: 0x101, sp: 0xFFFC, cycles: 16}
    assert MMU.read(0xFFFD) == <<0x01>>
    assert MMU.read(0xFFFC) == <<0x4D>>
  end

  test "0xE6 - AND A, D8" do
    assert Ops.decode(<<0xE6>>, @default) == %{@default | 6 => <<0x20>>, 7 => <<0x01>>, pc: 0x102, cycles: 8}
  end

  test "0xE7 - RST 20" do
    assert Ops.decode(<<0xE7>>, %{@default | pc: 0x1233}) == %{@default | pc: 0x20, sp: 0xFFFC, cycles: 16}
    assert MMU.read(0xFFFD) == <<0x12>>
    assert MMU.read(0xFFFC) == <<0x34>> # decode adds 1
  end

  test "0xE8 - ADD SP, R8" do
    assert Ops.decode(<<0xE8>>, @default) == %{@default | 6 => <<0x30>>, sp: 0xFFC1, pc: 0x102, cycles: 16}
  end

  test "0xE9 - JUMP (HL)" do
    assert Ops.decode(<<0xE9>>, @default) == %{@default | pc: 0x014D, cycles: 4}
  end

  test "0xEA - LD (a16), A" do
    assert Ops.decode(<<0xEA>>, %{@default | pc: 0x11B}) == %{@default | pc: 0x11E, cycles: 16}
    assert MMU.read(0xCCDC) == <<0x01>>
  end

  test "0xEE - XOR d8 A" do
    assert Ops.decode(<<0xEE>>, @default) == %{@default | 7 => <<0xC2>>, 6 => <<0x00>>, pc: 0x102, cycles: 8}
  end

  test "0xEF - RST 28" do
    assert Ops.decode(<<0xEF>>, %{@default | pc: 0x1233}) == %{@default | pc: 0x28, sp: 0xFFFC, cycles: 16}
    assert MMU.read(0xFFFD) == <<0x12>>
    assert MMU.read(0xFFFC) == <<0x34>> # decode adds 1
  end

  test "0xF0 - LDH A, (a8)" do
    assert MMU.read(0xFFC3) == <<0>>
    MMU.write(0xFFC3, <<0x10>>)
    assert MMU.read(0xFFC3) == <<0x10>>
    assert Ops.decode(<<0xF0>>, @default) == %{@default | 7 => <<0x10>>, pc: 0x102, cycles: 12}
  end

  test "0xF1 - POP AF" do
    MMU.write(0xFFFD, <<0x12>>)
    MMU.write(0xFFFC, <<0x34>>)
    assert Ops.decode(<<0xF1>>, %{@default | sp: 0xFFFC}) == %{@default | 6 => <<0x30>>, 7 => <<0x12>>, sp: 0xFFFE, pc: 0x101, cycles: 12}
  end

  test "0xF2 - LDH A, (C)" do
    MMU.write(0xFF13, <<0x10>>)
    assert Ops.decode(<<0xF2>>, @default) == %{@default | 7 => <<0x10>>, pc: 0x101, cycles: 8}
  end

  test "0xF3 - EI" do
    assert Ops.decode(<<0xF3>>, @default) == %{@default | ime: 0, pc: 0x101, cycles: 4}
  end

  test " 0xF5 PUSH AF" do
    assert Ops.decode(<<0xF5>>, @default) == %{@default | pc: 0x101, sp: 0xFFFC, cycles: 16}
    assert MMU.read(0xFFFD) == <<0x01>>
    assert MMU.read(0xFFFC) == <<0xB0>>
  end

  test "0xF6 - OR A, D8" do
    assert Ops.decode(<<0xF6>>, @default) == %{@default | 6 => <<0x00>>, 7 => <<0xC3>>, pc: 0x102, cycles: 8}
  end

  test "0xF7 - RST 30" do
    assert Ops.decode(<<0xF7>>, %{@default | pc: 0x1233}) == %{@default | pc: 0x30, sp: 0xFFFC, cycles: 16}
    assert MMU.read(0xFFFD) == <<0x12>>
    assert MMU.read(0xFFFC) == <<0x34>> # decode adds 1 to pc
  end

  test "0xF8 - LD HL, SP + R8" do
    assert Ops.decode(<<0xF8>>, @default) == %{@default | 4 => <<0xFF>>, 5 => <<0xC1>>, 6 => <<0x30>>, pc: 0x101, cycles: 12}
  end

  test "0xFA - LD A, (a16)" do
    MMU.write(0xCCDC, <<0x10>>)
    assert Ops.decode(<<0xFA>>, %{@default | pc: 0x11B}) == %{@default | 7 => <<0x10>>, pc: 0x11E, cycles: 16}
  end

  test "0xFB - DI" do
    assert Ops.decode(<<0xFB>>, @default) == %{@default | ime: 1, pc: 0x101, cycles: 4}
  end

  test "0xF9 - LD SP, HL" do
    assert Ops.decode(<<0xF9>>, @default) == %{@default | pc: 0x101, sp: 0x014D, cycles: 8}
  end

  test "0xFE - CP d8 A" do
    assert Ops.decode(<<0xFE>>, %{@default | 7 => <<0xC3>>}) == %{@default | 7 => <<0xC3>>, 6 => <<0xC0>>, pc: 0x102, cycles: 8}
  end

  test "0xFF - RST 38" do
    assert Ops.decode(<<0xFF>>, %{@default | pc: 0x1233}) == %{@default | pc: 0x38, sp: 0xFFFC, cycles: 16}
    assert MMU.read(0xFFFD) == <<0x12>>
    assert MMU.read(0xFFFC) == <<0x34>> # decode adds 1
  end
end
