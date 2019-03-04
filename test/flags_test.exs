defmodule GameKunFlagsTest do
  use ExUnit.Case
  doctest GameKun.Flags
  alias GameKun.Flags

  test "Z" do
    assert Flags.z_f(<<0>>) == 128
    assert Flags.z_f(<<1>>) == 0
  end

  test "C-8" do
    # Addition
    assert Flags.c_f_8(0, 0, 0) == 0
    assert Flags.c_f_8(0, 100, 100) == 0
    assert Flags.c_f_8(0, 200, 200) == 16
    assert Flags.c_f_8(0, 255, 1) == 16
    # Addition w/ Carry
    assert Flags.c_f_8(0, 0, 0, 1) == 0
    assert Flags.c_f_8(0, 100, 100, 1) == 0
    assert Flags.c_f_8(0, 200, 200, 1) == 16
    assert Flags.c_f_8(0, 254, 1, 1) == 16
    # Subtraction
    assert Flags.c_f_8(1, 0, 0) == 0
    assert Flags.c_f_8(1, 100, 100) == 0
    assert Flags.c_f_8(1, 30, 200) == 16
    assert Flags.c_f_8(1, 1, 25) == 16
    assert Flags.c_f_8(1, 19, 1) == 0
    # Subtraction w/ Carry
    assert Flags.c_f_8(1, 0, 1, 0) == 16
    assert Flags.c_f_8(1, 0, 0, 1) == 16
    assert Flags.c_f_8(1, 100, 99, 1) == 0
    assert Flags.c_f_8(1, 200, 200, 1) == 16
    assert Flags.c_f_8(1, 254, 1, 1) == 0
  end

  test "H-8" do
    # Addition
    assert Flags.h_f_8(0, 0, 0) == 0
    assert Flags.h_f_8(0, 100, 100) == 0
    assert Flags.h_f_8(0, 200, 200) == 32
    assert Flags.h_f_8(0, 255, 1) == 32
    # Addition w/ Carry
    assert Flags.h_f_8(0, 0, 0, 1) == 0
    assert Flags.h_f_8(0, 100, 100, 1) == 0
    assert Flags.h_f_8(0, 199, 200, 1) == 32
    assert Flags.h_f_8(0, 254, 1, 1) == 32
    assert Flags.h_f_8(0, 255, 1, 1) == 32
    # Subtraction
    assert Flags.h_f_8(1, 0, 0) == 0
    assert Flags.h_f_8(1, 100, 100) == 0
    assert Flags.h_f_8(1, 30, 200) == 0
    assert Flags.h_f_8(1, 1, 25) == 32
    assert Flags.h_f_8(1, 19, 4) == 32
    assert Flags.c_f_8(1, 19, 1) == 0
    # Subtraction w/ Carry
    assert Flags.h_f_8(1, 0, 0, 1) == 32
    assert Flags.h_f_8(1, 100, 99, 1) == 0
    assert Flags.h_f_8(1, 200, 200, 1) == 32
    assert Flags.h_f_8(1, 254, 1, 1) == 0
  end

  test "C-16" do
    # Addition
    assert Flags.c_f_16(0, 0, 0) == 0
    assert Flags.c_f_16(0, 0xFF, 0xFF) == 0
    assert Flags.c_f_16(0, 0xFFFF, 1) == 0x10
    assert Flags.c_f_16(0, 0xFFFF, 0xFFFF) == 0x10
    assert Flags.c_f_16(0, 0x014F, 0xFFFE) == 0x10
  end

  test "H-16" do
    # Addition
    assert Flags.h_f_16(0, 0, 0) == 0
    assert Flags.h_f_16(0, 0xFF, 0xFF) == 0
    assert Flags.h_f_16(0, 0xFFFF, 1) == 0x20
    assert Flags.h_f_16(0, 0xFFFF, 0xFFFF) == 0x20
    assert Flags.h_f_16(0, 0x0FFF, 0) == 0
    assert Flags.h_f_16(0, 0x0FFF, 1) == 0x20
  end
end
