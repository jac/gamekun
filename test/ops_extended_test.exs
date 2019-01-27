defmodule GameKunOpsExtendedTest do
  use ExUnit.Case
  doctest GameKun.Ops.Extended
  alias GameKun.Ops.Extended, as: Ex

  @default Application.fetch_env!(:gamekun, :gb_reg)

  setup do
    cart = start_supervised!({GameKun.Cart, "./cpu_instrs.gb"})
    %{cart: cart}
  end

  test "0x00.. RLC reg" do
    assert Ex.decode(<<0x00>>, %{@default | 0 => <<5>>, 6 => <<0>>}) == %{@default | 0 => <<10>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x01>>, %{@default | 1 => <<0>>, 6 => <<0>>}) == %{@default | 1 => <<0>>, 6 => <<128>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x02>>, %{@default | 2 => <<128>>, 6 => <<0>>}) == %{@default | 2 => <<1>>, 6 => <<16>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x03>>, %{@default | 3 => <<0>>, 6 => <<16>>}) == %{@default | 3 => <<0>>, 6 => <<128>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x04>>, %{@default | 4 => <<128>>, 6 => <<16>>}) == %{@default | 4 => <<1>>, 6 => <<16>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x05>>, %{@default | 5 => <<255>>, 6 => <<128>>}) == %{@default | 5 => <<255>>, 6 => <<16>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x07>>, %{@default | 7 => <<254>>, 6 => <<64>>}) == %{@default | 7 => <<253>>, 6 => <<16>>, pc: 0x101, cycles: 4}
  end

  test "0x08.. RRC reg" do
    assert Ex.decode(<<0x08>>, %{@default | 0 => <<5>>, 6 => <<0>>}) == %{@default | 0 => <<130>>, 6 => <<16>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x09>>, %{@default | 1 => <<0>>, 6 => <<0>>}) == %{@default | 1 => <<0>>, 6 => <<128>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x0A>>, %{@default | 2 => <<128>>, 6 => <<0>>}) == %{@default | 2 => <<64>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x0B>>, %{@default | 3 => <<0>>, 6 => <<16>>}) == %{@default | 3 => <<0>>, 6 => <<128>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x0C>>, %{@default | 4 => <<128>>, 6 => <<16>>}) == %{@default | 4 => <<64>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x0D>>, %{@default | 5 => <<255>>, 6 => <<16>>}) == %{@default | 5 => <<255>>, 6 => <<16>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x0F>>, %{@default | 7 => <<254>>, 6 => <<64>>}) == %{@default | 7 => <<127>>, 6 => <<0>>, pc: 0x101, cycles: 4}
  end

  test "0x10.. RL reg" do
    assert Ex.decode(<<0x10>>, %{@default | 0 => <<5>>, 6 => <<0>>}) == %{@default | 0 => <<10>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x11>>, %{@default | 1 => <<0>>, 6 => <<0>>}) == %{@default | 1 => <<0>>, 6 => <<128>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x12>>, %{@default | 2 => <<128>>, 6 => <<0>>}) == %{@default | 2 => <<0>>, 6 => <<144>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x13>>, %{@default | 3 => <<0>>, 6 => <<16>>}) == %{@default | 3 => <<1>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x14>>, %{@default | 4 => <<128>>, 6 => <<16>>}) == %{@default | 4 => <<1>>, 6 => <<16>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x15>>, %{@default | 5 => <<255>>, 6 => <<16>>}) == %{@default | 5 => <<255>>, 6 => <<16>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x17>>, %{@default | 7 => <<255>>, 6 => <<0>>}) == %{@default | 7 => <<254>>, 6 => <<16>>, pc: 0x101, cycles: 4}
  end

  test "0x18.. RR reg" do
    assert Ex.decode(<<0x18>>, %{@default | 0 => <<5>>, 6 => <<0>>}) == %{@default | 0 => <<2>>, 6 => <<16>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x19>>, %{@default | 1 => <<6>>, 6 => <<0>>}) == %{@default | 1 => <<3>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x1A>>, %{@default | 2 => <<1>>, 6 => <<0>>}) == %{@default | 2 => <<0>>, 6 => <<144>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x1B>>, %{@default | 3 => <<1>>, 6 => <<16>>}) == %{@default | 3 => <<128>>, 6 => <<16>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x1C>>, %{@default | 4 => <<128>>, 6 => <<16>>}) == %{@default | 4 => <<192>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x1D>>, %{@default | 5 => <<0>>, 6 => <<16>>}) == %{@default | 5 => <<128>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x1F>>, %{@default | 7 => <<0>>, 6 => <<0>>}) == %{@default | 7 => <<0>>, 6 => <<128>>, pc: 0x101, cycles: 4}
  end

  test "0x20.. SLA reg" do
    assert Ex.decode(<<0x20>>, %{@default | 0 => <<5>>, 6 => <<16>>}) == %{@default | 0 => <<10>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x21>>, %{@default | 1 => <<0>>, 6 => <<0>>}) == %{@default | 1 => <<0>>, 6 => <<128>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x22>>, %{@default | 2 => <<128>>, 6 => <<0>>}) == %{@default | 2 => <<0>>, 6 => <<144>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x23>>, %{@default | 3 => <<0>>, 6 => <<16>>}) == %{@default | 3 => <<0>>, 6 => <<128>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x24>>, %{@default | 4 => <<128>>, 6 => <<16>>}) == %{@default | 4 => <<0>>, 6 => <<144>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x25>>, %{@default | 5 => <<255>>, 6 => <<16>>}) == %{@default | 5 => <<254>>, 6 => <<16>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x27>>, %{@default | 7 => <<255>>, 6 => <<0>>}) == %{@default | 7 => <<254>>, 6 => <<16>>, pc: 0x101, cycles: 4}
  end

  test "0x28.. SRA reg" do
    assert Ex.decode(<<0x28>>, %{@default | 0 => <<5>>, 6 => <<0>>}) == %{@default | 0 => <<2>>, 6 => <<16>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x29>>, %{@default | 1 => <<6>>, 6 => <<0>>}) == %{@default | 1 => <<3>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x2A>>, %{@default | 2 => <<1>>, 6 => <<0>>}) == %{@default | 2 => <<0>>, 6 => <<144>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x2B>>, %{@default | 3 => <<1>>, 6 => <<16>>}) == %{@default | 3 => <<0>>, 6 => <<144>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x2C>>, %{@default | 4 => <<128>>, 6 => <<16>>}) == %{@default | 4 => <<192>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x2D>>, %{@default | 5 => <<127>>, 6 => <<16>>}) == %{@default | 5 => <<63>>, 6 => <<16>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x2F>>, %{@default | 7 => <<255>>, 6 => <<128>>}) == %{@default | 7 => <<255>>, 6 => <<16>>, pc: 0x101, cycles: 4}
  end

  test "0x30.. SWAP reg" do
    assert Ex.decode(<<0x30>>, %{@default | 0 => <<5>>}) == %{@default | 0 => <<80>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x31>>, %{@default | 1 => <<0>>}) == %{@default | 1 => <<0>>, 6 => <<128>>, pc: 0x101,cycles: 4}
    assert Ex.decode(<<0x32>>, %{@default | 2 => <<128>>}) == %{@default | 2 => <<8>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x33>>, %{@default | 3 => <<60>>}) == %{@default | 3 => <<195>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x34>>, %{@default | 4 => <<127>>}) == %{@default | 4 => <<247>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x35>>, %{@default | 5 => <<165>>}) == %{@default | 5 => <<90>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x37>>, %{@default | 7 => <<253>>}) == %{@default | 7 => <<223>>, 6 => <<0>>, pc: 0x101, cycles: 4}
  end

  test "0x38.. SRL reg" do
    assert Ex.decode(<<0x38>>, %{@default | 0 => <<5>>, 6 => <<0>>}) == %{@default | 0 => <<2>>, 6 => <<16>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x39>>, %{@default | 1 => <<6>>, 6 => <<0>>}) == %{@default | 1 => <<3>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x3A>>, %{@default | 2 => <<1>>, 6 => <<0>>}) == %{@default | 2 => <<0>>, 6 => <<144>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x3B>>, %{@default | 3 => <<1>>, 6 => <<16>>}) == %{@default | 3 => <<0>>, 6 => <<144>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x3C>>, %{@default | 4 => <<128>>, 6 => <<16>>}) == %{@default | 4 => <<64>>, 6 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x3D>>, %{@default | 5 => <<129>>, 6 => <<128>>}) == %{@default | 5 => <<64>>, 6 => <<16>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x3F>>, %{@default | 7 => <<255>>, 6 => <<128>>}) == %{@default | 7 => <<127>>, 6 => <<16>>, pc: 0x101, cycles: 4}
  end

  test "0x40.. Bit pos, reg" do
    # 0
    assert Ex.decode(<<0x40>>, %{@default | 0 => <<0>>, 6 => <<0>>}) == %{@default | 0 => <<0>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x41>>, %{@default | 1 => <<1>>, 6 => <<16>>}) == %{@default | 1 => <<1>>, 6 => <<48>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x42>>, %{@default | 2 => <<2>>, 6 => <<32>>}) == %{@default | 2 => <<2>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x43>>, %{@default | 3 => <<3>>, 6 => <<128>>}) == %{@default | 3 => <<3>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x44>>, %{@default | 4 => <<4>>, 6 => <<0>>}) == %{@default | 4 => <<4>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x45>>, %{@default | 5 => <<5>>, 6 => <<16>>}) == %{@default | 5 => <<5>>, 6 => <<48>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x47>>, %{@default | 7 => <<7>>, 6 => <<128>>}) == %{@default | 7 => <<7>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    # 1
    assert Ex.decode(<<0x48>>, %{@default | 0 => <<8>>, 6 => <<144>>}) == %{@default | 0 => <<8>>, 6 => <<176>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x49>>, %{@default | 1 => <<9>>, 6 => <<192>>}) == %{@default | 1 => <<9>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x4A>>, %{@default | 2 => <<10>>, 6 => <<0>>}) == %{@default | 2 => <<10>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x4B>>, %{@default | 3 => <<11>>, 6 => <<48>>}) == %{@default | 3 => <<11>>, 6 => <<48>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x4C>>, %{@default | 4 => <<12>>, 6 => <<160>>}) == %{@default | 4 => <<12>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x4D>>, %{@default | 5 => <<13>>, 6 => <<0>>}) == %{@default | 5 => <<13>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x4F>>, %{@default | 7 => <<15>>, 6 => <<16>>}) == %{@default | 7 => <<15>>, 6 => <<48>>, pc: 0x101, cycles: 4}
    # 2
    assert Ex.decode(<<0x50>>, %{@default | 0 => <<16>>, 6 => <<32>>}) == %{@default | 0 => <<16>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x51>>, %{@default | 1 => <<17>>, 6 => <<128>>}) == %{@default | 1 => <<17>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x52>>, %{@default | 2 => <<18>>, 6 => <<0>>}) == %{@default | 2 => <<18>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x53>>, %{@default | 3 => <<19>>, 6 => <<16>>}) == %{@default | 3 => <<19>>, 6 => <<176>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x54>>, %{@default | 4 => <<20>>, 6 => <<128>>}) == %{@default | 4 => <<20>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x55>>, %{@default | 5 => <<21>>, 6 => <<144>>}) == %{@default | 5 => <<21>>, 6 => <<48>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x57>>, %{@default | 7 => <<23>>, 6 => <<192>>}) == %{@default | 7 => <<23>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    # 3
    assert Ex.decode(<<0x58>>, %{@default | 0 => <<24>>, 6 => <<0>>}) == %{@default | 0 => <<24>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x59>>, %{@default | 1 => <<25>>, 6 => <<48>>}) == %{@default | 1 => <<25>>, 6 => <<48>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x5A>>, %{@default | 2 => <<26>>, 6 => <<160>>}) == %{@default | 2 => <<26>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x5B>>, %{@default | 3 => <<27>>, 6 => <<0>>}) == %{@default | 3 => <<27>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x5C>>, %{@default | 4 => <<28>>, 6 => <<16>>}) == %{@default | 4 => <<28>>, 6 => <<48>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x5D>>, %{@default | 5 => <<29>>, 6 => <<32>>}) == %{@default | 5 => <<29>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x5F>>, %{@default | 7 => <<31>>, 6 => <<128>>}) == %{@default | 7 => <<31>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    # 4
    assert Ex.decode(<<0x60>>, %{@default | 0 => <<32>>, 6 => <<0>>}) == %{@default | 0 => <<32>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x61>>, %{@default | 1 => <<33>>, 6 => <<16>>}) == %{@default | 1 => <<33>>, 6 => <<176>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x62>>, %{@default | 2 => <<34>>, 6 => <<128>>}) == %{@default | 2 => <<34>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x63>>, %{@default | 3 => <<35>>, 6 => <<144>>}) == %{@default | 3 => <<35>>, 6 => <<176>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x64>>, %{@default | 4 => <<36>>, 6 => <<192>>}) == %{@default | 4 => <<36>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x65>>, %{@default | 5 => <<37>>, 6 => <<0>>}) == %{@default | 5 => <<37>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x67>>, %{@default | 7 => <<39>>, 6 => <<48>>}) == %{@default | 7 => <<39>>, 6 => <<176>>, pc: 0x101, cycles: 4}
    # 5
    assert Ex.decode(<<0x68>>, %{@default | 0 => <<40>>, 6 => <<160>>}) == %{@default | 0 => <<40>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x69>>, %{@default | 1 => <<41>>, 6 => <<0>>}) == %{@default | 1 => <<41>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x6A>>, %{@default | 2 => <<42>>, 6 => <<16>>}) == %{@default | 2 => <<42>>, 6 => <<48>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x6B>>, %{@default | 3 => <<43>>, 6 => <<32>>}) == %{@default | 3 => <<43>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x6C>>, %{@default | 4 => <<44>>, 6 => <<48>>}) == %{@default | 4 => <<44>>, 6 => <<48>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x6D>>, %{@default | 5 => <<45>>, 6 => <<144>>}) == %{@default | 5 => <<45>>, 6 => <<48>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x6F>>, %{@default | 7 => <<47>>, 6 => <<128>>}) == %{@default | 7 => <<47>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    # 6
    assert Ex.decode(<<0x70>>, %{@default | 0 => <<48>>, 6 => <<192>>}) == %{@default | 0 => <<48>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x71>>, %{@default | 1 => <<49>>, 6 => <<0>>}) == %{@default | 1 => <<49>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x72>>, %{@default | 2 => <<50>>, 6 => <<16>>}) == %{@default | 2 => <<50>>, 6 => <<176>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x73>>, %{@default | 3 => <<51>>, 6 => <<32>>}) == %{@default | 3 => <<51>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x74>>, %{@default | 4 => <<52>>, 6 => <<240>>}) == %{@default | 4 => <<52>>, 6 => <<176>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x75>>, %{@default | 5 => <<53>>, 6 => <<224>>}) == %{@default | 5 => <<53>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x77>>, %{@default | 7 => <<55>>, 6 => <<192>>}) == %{@default | 7 => <<55>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    # 7
    assert Ex.decode(<<0x78>>, %{@default | 0 => <<128>>, 6 => <<16>>}) == %{@default | 0 => <<128>>, 6 => <<48>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x79>>, %{@default | 1 => <<127>>, 6 => <<0>>}) == %{@default | 1 => <<127>>, 6 => <<160>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x7A>>, %{@default | 2 => <<255>>, 6 => <<128>>}) == %{@default | 2 => <<255>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x7B>>, %{@default | 3 => <<0>>, 6 => <<48>>}) == %{@default | 3 => <<0>>, 6 => <<176>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x7C>>, %{@default | 4 => <<200>>, 6 => <<64>>}) == %{@default | 4 => <<200>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x7D>>, %{@default | 5 => <<129>>, 6 => <<96>>}) == %{@default | 5 => <<129>>, 6 => <<32>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x7F>>, %{@default | 7 => <<67>>, 6 => <<80>>}) == %{@default | 7 => <<67>>, 6 => <<176>>, pc: 0x101, cycles: 4}
  end

  test "0x80.. RES pos, reg" do
    # 0
    assert Ex.decode(<<0x80>>, %{@default | 0 => <<0>>}) == %{@default | 0 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x81>>, %{@default | 1 => <<1>>}) == %{@default | 1 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x82>>, %{@default | 2 => <<2>>}) == %{@default | 2 => <<2>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x83>>, %{@default | 3 => <<3>>}) == %{@default | 3 => <<2>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x84>>, %{@default | 4 => <<4>>}) == %{@default | 4 => <<4>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x85>>, %{@default | 5 => <<5>>}) == %{@default | 5 => <<4>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x87>>, %{@default | 7 => <<7>>}) == %{@default | 7 => <<6>>, pc: 0x101, cycles: 4}
    # 1
    assert Ex.decode(<<0x88>>, %{@default | 0 => <<8>>}) == %{@default | 0 => <<8>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x89>>, %{@default | 1 => <<9>>}) == %{@default | 1 => <<9>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x8A>>, %{@default | 2 => <<10>>}) == %{@default | 2 => <<8>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x8B>>, %{@default | 3 => <<11>>}) == %{@default | 3 => <<9>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x8C>>, %{@default | 4 => <<12>>}) == %{@default | 4 => <<12>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x8D>>, %{@default | 5 => <<13>>}) == %{@default | 5 => <<13>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x8F>>, %{@default | 7 => <<15>>}) == %{@default | 7 => <<13>>, pc: 0x101, cycles: 4}
    # 2
    assert Ex.decode(<<0x90>>, %{@default | 0 => <<16>>}) == %{@default | 0 => <<16>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x91>>, %{@default | 1 => <<17>>}) == %{@default | 1 => <<17>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x92>>, %{@default | 2 => <<18>>}) == %{@default | 2 => <<18>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x93>>, %{@default | 3 => <<19>>}) == %{@default | 3 => <<19>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x94>>, %{@default | 4 => <<20>>}) == %{@default | 4 => <<16>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x95>>, %{@default | 5 => <<21>>}) == %{@default | 5 => <<17>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x97>>, %{@default | 7 => <<23>>}) == %{@default | 7 => <<19>>, pc: 0x101, cycles: 4}
    # 3
    assert Ex.decode(<<0x98>>, %{@default | 0 => <<104>>}) == %{@default | 0 => <<96>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x99>>, %{@default | 1 => <<105>>}) == %{@default | 1 => <<97>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x9A>>, %{@default | 2 => <<106>>}) == %{@default | 2 => <<98>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x9B>>, %{@default | 3 => <<107>>}) == %{@default | 3 => <<99>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x9C>>, %{@default | 4 => <<108>>}) == %{@default | 4 => <<100>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x9D>>, %{@default | 5 => <<109>>}) == %{@default | 5 => <<101>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0x9F>>, %{@default | 7 => <<111>>}) == %{@default | 7 => <<103>>, pc: 0x101, cycles: 4}
    # 4
    assert Ex.decode(<<0xA0>>, %{@default | 0 => <<32>>}) == %{@default | 0 => <<32>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xA1>>, %{@default | 1 => <<33>>}) == %{@default | 1 => <<33>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xA2>>, %{@default | 2 => <<34>>}) == %{@default | 2 => <<34>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xA3>>, %{@default | 3 => <<35>>}) == %{@default | 3 => <<35>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xA4>>, %{@default | 4 => <<36>>}) == %{@default | 4 => <<36>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xA5>>, %{@default | 5 => <<37>>}) == %{@default | 5 => <<37>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xA7>>, %{@default | 7 => <<39>>}) == %{@default | 7 => <<39>>, pc: 0x101, cycles: 4}
    # 5
    assert Ex.decode(<<0xA8>>, %{@default | 0 => <<160>>}) == %{@default | 0 => <<128>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xA9>>, %{@default | 1 => <<161>>}) == %{@default | 1 => <<129>>, pc: 0x101,cycles: 4}
    assert Ex.decode(<<0xAA>>, %{@default | 2 => <<130>>}) == %{@default | 2 => <<130>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xAB>>, %{@default | 3 => <<162>>}) == %{@default | 3 => <<130>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xAC>>, %{@default | 4 => <<163>>}) == %{@default | 4 => <<131>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xAD>>, %{@default | 5 => <<164>>}) == %{@default | 5 => <<132>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xAF>>, %{@default | 7 => <<166>>}) == %{@default | 7 => <<134>>, pc: 0x101, cycles: 4}
    # 6
    assert Ex.decode(<<0xB0>>, %{@default | 0 => <<200>>}) == %{@default | 0 => <<136>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xB1>>, %{@default | 1 => <<201>>}) == %{@default | 1 => <<137>>, pc: 0x101,cycles: 4}
    assert Ex.decode(<<0xB2>>, %{@default | 2 => <<202>>}) == %{@default | 2 => <<138>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xB3>>, %{@default | 3 => <<130>>}) == %{@default | 3 => <<130>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xB4>>, %{@default | 4 => <<204>>}) == %{@default | 4 => <<140>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xB5>>, %{@default | 5 => <<205>>}) == %{@default | 5 => <<141>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xB7>>, %{@default | 7 => <<207>>}) == %{@default | 7 => <<143>>, pc: 0x101, cycles: 4}
    # 7
    assert Ex.decode(<<0xB8>>, %{@default | 0 => <<128>>}) == %{@default | 0 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xB9>>, %{@default | 1 => <<127>>}) == %{@default | 1 => <<127>>, pc: 0x101,cycles: 4}
    assert Ex.decode(<<0xBA>>, %{@default | 2 => <<255>>}) == %{@default | 2 => <<127>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xBB>>, %{@default | 3 => <<0>>}) == %{@default | 3 => <<0>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xBC>>, %{@default | 4 => <<200>>}) == %{@default | 4 => <<72>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xBD>>, %{@default | 5 => <<129>>}) == %{@default | 5 => <<1>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xBF>>, %{@default | 7 => <<67>>}) == %{@default | 7 => <<67>>, pc: 0x101, cycles: 4}
  end

  test "0xC0.. SET pos, reg" do
    # 0
    assert Ex.decode(<<0xC0>>, %{@default | 0 => <<0>>}) == %{@default | 0 => <<1>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xC1>>, %{@default | 1 => <<1>>}) == %{@default | 1 => <<1>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xC2>>, %{@default | 2 => <<2>>}) == %{@default | 2 => <<3>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xC3>>, %{@default | 3 => <<3>>}) == %{@default | 3 => <<3>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xC4>>, %{@default | 4 => <<4>>}) == %{@default | 4 => <<5>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xC5>>, %{@default | 5 => <<5>>}) == %{@default | 5 => <<5>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xC7>>, %{@default | 7 => <<7>>}) == %{@default | 7 => <<7>>, pc: 0x101, cycles: 4}
    # 1
    assert Ex.decode(<<0xC8>>, %{@default | 0 => <<8>>}) == %{@default | 0 => <<10>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xC9>>, %{@default | 1 => <<9>>}) == %{@default | 1 => <<11>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xCA>>, %{@default | 2 => <<10>>}) == %{@default | 2 => <<10>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xCB>>, %{@default | 3 => <<11>>}) == %{@default | 3 => <<11>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xCC>>, %{@default | 4 => <<12>>}) == %{@default | 4 => <<14>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xCD>>, %{@default | 5 => <<13>>}) == %{@default | 5 => <<15>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xCF>>, %{@default | 7 => <<15>>}) == %{@default | 7 => <<15>>, pc: 0x101, cycles: 4}
    # 2
    assert Ex.decode(<<0xD0>>, %{@default | 0 => <<16>>}) == %{@default | 0 => <<20>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xD1>>, %{@default | 1 => <<17>>}) == %{@default | 1 => <<21>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xD2>>, %{@default | 2 => <<18>>}) == %{@default | 2 => <<22>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xD3>>, %{@default | 3 => <<19>>}) == %{@default | 3 => <<23>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xD4>>, %{@default | 4 => <<20>>}) == %{@default | 4 => <<20>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xD5>>, %{@default | 5 => <<21>>}) == %{@default | 5 => <<21>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xD7>>, %{@default | 7 => <<23>>}) == %{@default | 7 => <<23>>, pc: 0x101, cycles: 4}
    # 3
    assert Ex.decode(<<0xD8>>, %{@default | 0 => <<70>>}) == %{@default | 0 => <<78>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xD9>>, %{@default | 1 => <<71>>}) == %{@default | 1 => <<79>>, pc: 0x101,cycles: 4}
    assert Ex.decode(<<0xDA>>, %{@default | 2 => <<72>>}) == %{@default | 2 => <<72>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xDB>>, %{@default | 3 => <<73>>}) == %{@default | 3 => <<73>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xDC>>, %{@default | 4 => <<80>>}) == %{@default | 4 => <<88>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xDD>>, %{@default | 5 => <<81>>}) == %{@default | 5 => <<89>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xDF>>, %{@default | 7 => <<82>>}) == %{@default | 7 => <<90>>, pc: 0x101, cycles: 4}
    # 4
    assert Ex.decode(<<0xE0>>, %{@default | 0 => <<32>>}) == %{@default | 0 => <<48>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xE1>>, %{@default | 1 => <<33>>}) == %{@default | 1 => <<49>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xE2>>, %{@default | 2 => <<34>>}) == %{@default | 2 => <<50>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xE3>>, %{@default | 3 => <<35>>}) == %{@default | 3 => <<51>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xE4>>, %{@default | 4 => <<36>>}) == %{@default | 4 => <<52>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xE5>>, %{@default | 5 => <<37>>}) == %{@default | 5 => <<53>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xE7>>, %{@default | 7 => <<39>>}) == %{@default | 7 => <<55>>, pc: 0x101, cycles: 4}
    # 5
    assert Ex.decode(<<0xE8>>, %{@default | 0 => <<0>>}) == %{@default | 0 => <<32>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xE9>>, %{@default | 1 => <<1>>}) == %{@default | 1 => <<33>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xEA>>, %{@default | 2 => <<2>>}) == %{@default | 2 => <<34>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xEB>>, %{@default | 3 => <<3>>}) == %{@default | 3 => <<35>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xEC>>, %{@default | 4 => <<4>>}) == %{@default | 4 => <<36>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xED>>, %{@default | 5 => <<5>>}) == %{@default | 5 => <<37>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xEF>>, %{@default | 7 => <<7>>}) == %{@default | 7 => <<39>>, pc: 0x101, cycles: 4}
    # 6
    assert Ex.decode(<<0xF0>>, %{@default | 0 => <<48>>}) == %{@default | 0 => <<112>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xF1>>, %{@default | 1 => <<49>>}) == %{@default | 1 => <<113>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xF2>>, %{@default | 2 => <<50>>}) == %{@default | 2 => <<114>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xF3>>, %{@default | 3 => <<51>>}) == %{@default | 3 => <<115>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xF4>>, %{@default | 4 => <<52>>}) == %{@default | 4 => <<116>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xF5>>, %{@default | 5 => <<53>>}) == %{@default | 5 => <<117>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xF7>>, %{@default | 7 => <<55>>}) == %{@default | 7 => <<119>>, pc: 0x101, cycles: 4}
    # 7
    assert Ex.decode(<<0xF8>>, %{@default | 0 => <<128>>}) == %{@default | 0 => <<128>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xF9>>, %{@default | 1 => <<127>>}) == %{@default | 1 => <<255>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xFA>>, %{@default | 2 => <<255>>}) == %{@default | 2 => <<255>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xFB>>, %{@default | 3 => <<0>>}) == %{@default | 3 => <<128>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xFC>>, %{@default | 4 => <<200>>}) == %{@default | 4 => <<200>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xFD>>, %{@default | 5 => <<129>>}) == %{@default | 5 => <<129>>, pc: 0x101, cycles: 4}
    assert Ex.decode(<<0xFF>>, %{@default | 7 => <<67>>}) == %{@default | 7 => <<195>>, pc: 0x101, cycles: 4}
  end
end
