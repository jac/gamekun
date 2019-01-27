defmodule GameKunOpsTest do
  use ExUnit.Case
  doctest GameKun.Ops
  alias GameKun.Ops

  @default Application.fetch_env!(:gamekun, :gb_reg)

  setup do
    cart = start_supervised!({GameKun.Cart, "./cpu_instrs.gb"})
    %{cart: cart}
  end

  test "0x00 - nop" do
    assert Ops.decode(<<0x00>>, @default) == %{@default | cycles: 4, pc: 0x101}
  end

  test "0x40.. - LD B, reg" do
    assert Ops.decode(<<0x40>>, %{@default | 0 => <<5>>}) == %{@default | 0 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x41>>, %{@default | 1 => <<5>>}) == %{@default | 0 => <<5>>, 1 => <<5>>, pc: 0x101,cycles: 4}
    assert Ops.decode(<<0x42>>, %{@default | 2 => <<5>>}) == %{@default | 0 => <<5>>, 2 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x43>>, %{@default | 3 => <<5>>}) == %{@default | 0 => <<5>>, 3 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x44>>, %{@default | 4 => <<5>>}) == %{@default | 0 => <<5>>, 4 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x45>>, %{@default | 5 => <<5>>}) == %{@default | 0 => <<5>>, 5 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x47>>, %{@default | 7 => <<5>>}) == %{@default | 0 => <<5>>, 7 => <<5>>, pc: 0x101, cycles: 4}
  end

  test "0x48.. - LD C, reg" do
    assert Ops.decode(<<0x48>>, %{@default | 0 => <<5>>}) == %{@default | 1 => <<5>>, 0 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x49>>, %{@default | 1 => <<5>>}) == %{@default | 1 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x4A>>, %{@default | 2 => <<5>>}) == %{@default | 1 => <<5>>, 2 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x4B>>, %{@default | 3 => <<5>>}) == %{@default | 1 => <<5>>, 3 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x4C>>, %{@default | 4 => <<5>>}) == %{@default | 1 => <<5>>, 4 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x4D>>, %{@default | 5 => <<5>>}) == %{@default | 1 => <<5>>, 5 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x4F>>, %{@default | 7 => <<5>>}) == %{@default | 1 => <<5>>, 7 => <<5>>, pc: 0x101, cycles: 4}
  end

  test "0x50.. - LD D, reg" do
    assert Ops.decode(<<0x50>>, %{@default | 0 => <<5>>}) == %{@default | 2 => <<5>>, 0 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x51>>, %{@default | 1 => <<5>>}) == %{@default | 2 => <<5>>, 1 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x52>>, %{@default | 2 => <<5>>}) == %{@default | 2 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x53>>, %{@default | 3 => <<5>>}) == %{@default | 2 => <<5>>, 3 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x54>>, %{@default | 4 => <<5>>}) == %{@default | 2 => <<5>>, 4 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x55>>, %{@default | 5 => <<5>>}) == %{@default | 2 => <<5>>, 5 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x57>>, %{@default | 7 => <<5>>}) == %{@default | 2 => <<5>>, 7 => <<5>>, pc: 0x101, cycles: 4}
  end

  test "0x58.. - LD E, reg" do
    assert Ops.decode(<<0x58>>, %{@default | 0 => <<5>>}) == %{@default | 3 => <<5>>, 0 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x59>>, %{@default | 1 => <<5>>}) == %{@default | 3 => <<5>>, 1 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x5A>>, %{@default | 2 => <<5>>}) == %{@default | 3 => <<5>>, 2 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x5B>>, %{@default | 3 => <<5>>}) == %{@default | 3 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x5C>>, %{@default | 4 => <<5>>}) == %{@default | 3 => <<5>>, 4 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x5D>>, %{@default | 5 => <<5>>}) == %{@default | 3 => <<5>>, 5 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x5F>>, %{@default | 7 => <<5>>}) == %{@default | 3 => <<5>>, 7 => <<5>>, pc: 0x101, cycles: 4}
  end

  test "0x60.. - LD H, reg" do
    assert Ops.decode(<<0x60>>, %{@default | 0 => <<5>>}) == %{@default | 4 => <<5>>, 0 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x61>>, %{@default | 1 => <<5>>}) == %{@default | 4 => <<5>>, 1 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x62>>, %{@default | 2 => <<5>>}) == %{@default | 4 => <<5>>, 2 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x63>>, %{@default | 3 => <<5>>}) == %{@default | 4 => <<5>>, 3 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x64>>, %{@default | 4 => <<5>>}) == %{@default | 4 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x65>>, %{@default | 5 => <<5>>}) == %{@default | 4 => <<5>>, 5 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x67>>, %{@default | 7 => <<5>>}) == %{@default | 4 => <<5>>, 7 => <<5>>, pc: 0x101, cycles: 4}
  end

  test "0x68.. - LD L, reg" do
    assert Ops.decode(<<0x68>>, %{@default | 0 => <<5>>}) == %{@default | 5 => <<5>>, 0 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x69>>, %{@default | 1 => <<5>>}) == %{@default | 5 => <<5>>, 1 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x6A>>, %{@default | 2 => <<5>>}) == %{@default | 5 => <<5>>, 2 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x6B>>, %{@default | 3 => <<5>>}) == %{@default | 5 => <<5>>, 3 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x6C>>, %{@default | 4 => <<5>>}) == %{@default | 5 => <<5>>, 4 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x6D>>, %{@default | 5 => <<5>>}) == %{@default | 5 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x6F>>, %{@default | 7 => <<5>>}) == %{@default | 5 => <<5>>, 7 => <<5>>, pc: 0x101, cycles: 4}
  end

  test "0x78.. - LD L, reg" do
    assert Ops.decode(<<0x78>>, %{@default | 0 => <<5>>}) == %{@default | 7 => <<5>>, 0 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x79>>, %{@default | 1 => <<5>>}) == %{@default | 7 => <<5>>, 1 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x7A>>, %{@default | 2 => <<5>>}) == %{@default | 7 => <<5>>, 2 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x7B>>, %{@default | 3 => <<5>>}) == %{@default | 7 => <<5>>, 3 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x7C>>, %{@default | 4 => <<5>>}) == %{@default | 7 => <<5>>, 4 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x7D>>, %{@default | 5 => <<5>>}) == %{@default | 7 => <<5>>, 5 => <<5>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x7F>>, %{@default | 7 => <<5>>}) == %{@default | 7 => <<5>>, pc: 0x101,cycles: 4}
  end

  test "0x80.. - ADD A, reg" do
    assert Ops.decode(<<0x80>>, %{@default | 0 => <<15>>}) == %{@default | 7 => <<16>>, 0 => <<15>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x81>>, %{@default | 1 => <<5>>}) == %{@default | 7 => <<6>>, 1 => <<5>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x82>>, %{@default | 2 => <<255>>}) == %{@default | 7 => <<0>>, 2 => <<255>>, 6 => <<176>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x83>>, %{@default | 3 => <<5>>}) == %{@default | 7 => <<6>>, 3 => <<5>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x84>>, %{@default | 4 => <<5>>}) == %{@default | 7 => <<6>>, 4 => <<5>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x85>>, %{@default | 5 => <<5>>}) == %{@default | 7 => <<6>>, 5 => <<5>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x87>>, %{@default | 7 => <<5>>}) == %{@default | 7 => <<10>>, 6 => <<0>>, pc: 0x101, cycles: 4}
  end

  test "0x88.. - ADC A, reg" do
    assert Ops.decode(<<0x88>>, %{@default | 0 => <<15>>, 6 => <<128>>}) == %{@default | 7 => <<16>>, 0 => <<15>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x89>>, %{@default | 1 => <<5>>, 6 => <<64>>}) == %{@default | 7 => <<6>>, 1 => <<5>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x8A>>, %{@default | 2 => <<255>>, 6 => <<32>>}) == %{@default | 7 => <<0>>, 2 => <<255>>, 6 => <<176>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x8B>>, %{@default | 3 => <<255>>, 6 => <<16>>}) == %{@default | 7 => <<1>>, 3 => <<255>>, 6 => <<48>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x8C>>, %{@default | 4 => <<5>>, 6 => <<16>>}) == %{@default | 7 => <<7>>, 4 => <<5>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x8D>>, %{@default | 5 => <<5>>, 6 => <<0>>}) == %{@default | 7 => <<6>>, 5 => <<5>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x8F>>, %{@default | 7 => <<129>>, 6 => <<16>>}) == %{@default | 7 => <<3>>, 6 => <<16>>, pc: 0x101, cycles: 4}
  end

  test "0xB0.. - SUB A, reg" do
    assert Ops.decode(<<0x90>>, %{@default | 0 => <<1>>}) == %{@default | 7 => <<0>>, 0 => <<1>>, 6 => <<192>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x91>>, %{@default | 1 => <<0>>}) == %{@default | 7 => <<1>>, 1 => <<0>>, 6 => <<64>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x92>>, %{@default | 2 => <<3>>, 7 => <<2>>}) == %{@default | 7 => <<255>>, 2 => <<3>>, 6 => <<112>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x93>>, %{@default | 3 => <<2>>, 7 => <<128>>}) == %{@default | 7 => <<126>>, 3 => <<2>>, 6 => <<96>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x94>>, %{@default | 4 => <<2>>, 7 => <<200>>}) == %{@default | 7 => <<198>>, 4 => <<2>>, 6 => <<64>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x95>>, %{@default | 5 => <<8>>, 7 => <<100>>}) == %{@default | 7 => <<92>>, 5 => <<8>>, 6 => <<96>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x97>>, %{@default | 7 => <<7>>}) == %{@default | 7 => <<0>>, 6 => <<192>>, pc: 0x101, cycles: 4}
  end

  test "0x98.. - SBC A, reg" do
    assert Ops.decode(<<0x98>>, %{@default | 0 => <<1>>, 6 => <<0>>}) == %{@default | 7 => <<0>>, 0 => <<1>>, 6 => <<192>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x99>>, %{@default | 1 => <<2>>, 6 => <<16>>}) == %{@default | 7 => <<254>>, 1 => <<2>>, 6 => <<80>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x9A>>, %{@default | 2 => <<3>>, 7 => <<3>>, 6 => <<16>>}) == %{@default | 7 => <<255>>, 2 => <<3>>, 6 => <<80>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x9B>>, %{@default | 3 => <<2>>, 7 => <<128>>, 6 => <<16>>}) == %{@default | 7 => <<125>>, 3 => <<2>>, 6 => <<96>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x9C>>, %{@default | 4 => <<1>>, 7 => <<127>>, 6 => <<16>>}) == %{@default | 7 => <<125>>, 4 => <<1>>, 6 => <<64>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x9D>>, %{@default | 5 => <<8>>, 7 => <<100>>, 6 => <<0>>}) == %{@default | 7 => <<92>>, 5 => <<8>>, 6 => <<96>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0x9F>>, %{@default | 7 => <<8>>, 6 => <<16>>}) == %{@default | 7 => <<255>>, 6 => <<80>>, pc: 0x101, cycles: 4}
  end

  test "0xA0.. - AND A, reg" do
    assert Ops.decode(<<0xA0>>, %{@default | 0 => <<1>>}) == %{@default | 7 => <<1>>, 0 => <<1>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xA1>>, %{@default | 1 => <<2>>}) == %{@default | 7 => <<0>>, 1 => <<2>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xA2>>, %{@default | 2 => <<3>>}) == %{@default | 7 => <<1>>, 2 => <<3>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xA3>>, %{@default | 3 => <<4>>}) == %{@default | 7 => <<0>>, 3 => <<4>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xA4>>, %{@default | 4 => <<5>>}) == %{@default | 7 => <<1>>, 4 => <<5>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xA5>>, %{@default | 5 => <<6>>}) == %{@default | 7 => <<0>>, 5 => <<6>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xA7>>, %{@default | 7 => <<7>>}) == %{@default | 7 => <<7>>, 6 => <<32>>, pc: 0x101, cycles: 4}
  end

  test "0xA8.. - XOR A, reg" do
    assert Ops.decode(<<0xA8>>, %{@default | 0 => <<1>>}) == %{@default | 7 => <<0>>, 0 => <<1>>, 6 => <<128>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xA9>>, %{@default | 1 => <<2>>}) == %{@default | 7 => <<3>>, 1 => <<2>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xAA>>, %{@default | 2 => <<3>>}) == %{@default | 7 => <<2>>, 2 => <<3>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xAB>>, %{@default | 3 => <<4>>}) == %{@default | 7 => <<5>>, 3 => <<4>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xAC>>, %{@default | 4 => <<5>>}) == %{@default | 7 => <<4>>, 4 => <<5>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xAD>>, %{@default | 5 => <<6>>}) == %{@default | 7 => <<7>>, 5 => <<6>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xAF>>, %{@default | 7 => <<7>>}) == %{@default | 7 => <<0>>, 6 => <<128>>, pc: 0x101, cycles: 4}
  end

  test "0xB0.. - OR A, reg" do
    assert Ops.decode(<<0xB0>>, %{@default | 0 => <<1>>}) == %{@default | 7 => <<1>>, 0 => <<1>>,6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xB1>>, %{@default | 1 => <<2>>}) == %{@default | 7 => <<3>>, 1 => <<2>>,6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xB2>>, %{@default | 2 => <<3>>}) == %{@default | 7 => <<3>>, 2 => <<3>>,6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xB3>>, %{@default | 3 => <<4>>}) == %{@default | 7 => <<5>>, 3 => <<4>>,6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xB4>>, %{@default | 4 => <<5>>}) == %{@default | 7 => <<5>>, 4 => <<5>>,6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xB5>>, %{@default | 5 => <<6>>}) == %{@default | 7 => <<7>>, 5 => <<6>>,6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xB7>>, %{@default | 7 => <<0>>}) == %{@default | 7 => <<0>>, 6 => <<128>>, pc: 0x101, cycles: 4}
  end

  test "0xB8.. - CP A, reg" do
    assert Ops.decode(<<0xB8>>, %{@default | 0 => <<1>>, 6 => <<0>>}) == %{@default | 0 => <<1>>, 6 => <<192>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xB9>>, %{@default | 1 => <<0>>, 6 => <<0>>}) == %{@default | 1 => <<0>>, 6 => <<64>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xBA>>, %{@default | 2 => <<3>>, 6 => <<16>>}) == %{@default | 2 => <<3>>, 6 => <<112>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xBB>>, %{@default | 3 => <<2>>, 7 => <<2>>, 6 => <<16>>}) == %{@default | 7 => <<2>>, 3 => <<2>>, 6 => <<192>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xBC>>, %{@default | 4 => <<2>>, 7 => <<200>>, 6 => <<0>>}) == %{@default | 7 => <<200>>, 4 => <<2>>, 6 => <<64>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xBD>>, %{@default | 5 => <<8>>, 7 => <<100>>, 6 => <<0>>}) == %{@default | 7 => <<100>>, 5 => <<8>>, 6 => <<96>>, pc: 0x101, cycles: 4}
    assert Ops.decode(<<0xBF>>, %{@default | 7 => <<7>>, 6 => <<0>>}) == %{@default | 7 => <<7>>, 6 => <<192>>, pc: 0x101, cycles: 4}
  end

  test "0xC3 - jmp a16" do
    assert Ops.decode(<<0xC3>>, %{@default | pc: 0x101}) == %{@default | cycles: 16, pc: 0x0637}
  end


end
