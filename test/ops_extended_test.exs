defmodule GameKunOpsExtendedTest do
  use ExUnit.Case
  doctest GameKun.Ops.Extended
  alias GameKun.Ops.Extended, as: Ex
  alias GameKun.MMU

  @default Application.fetch_env!(:gamekun, :gb_reg)
  @rhs %{@default | pc: 0x101, cycles: 4}
  @rhs16 %{@default | pc: 0x101, cycles: 12}

  setup do
    cart = start_supervised!({GameKun.Cart, "./cpu_instrs.gb"})
    ram = start_supervised!({GameKun.RAM, nil})
    %{cart: cart, ram: ram}
  end

  test "0x00.. RLC reg" do
    assert Ex.decode(<<0x00>>, %{@default | 0 => <<5>>, 6 => <<0>>}) == %{@rhs | 0 => <<10>>, 6 => <<0>>}
    assert Ex.decode(<<0x01>>, %{@default | 1 => <<0>>, 6 => <<0>>}) == %{@rhs | 1 => <<0>>, 6 => <<128>>}
    assert Ex.decode(<<0x02>>, %{@default | 2 => <<128>>, 6 => <<0>>}) == %{@rhs | 2 => <<1>>, 6 => <<16>>}
    assert Ex.decode(<<0x03>>, %{@default | 3 => <<0>>, 6 => <<16>>}) == %{@rhs | 3 => <<0>>, 6 => <<128>>}
    assert Ex.decode(<<0x04>>, %{@default | 4 => <<128>>, 6 => <<16>>}) == %{@rhs | 4 => <<1>>, 6 => <<16>>}
    assert Ex.decode(<<0x05>>, %{@default | 5 => <<255>>, 6 => <<128>>}) == %{@rhs | 5 => <<255>>, 6 => <<16>>}
    assert Ex.decode(<<0x07>>, %{@default | 7 => <<254>>, 6 => <<64>>}) == %{@rhs | 7 => <<253>>, 6 => <<16>>}
  end

  test "0x06 RLC (HL)" do
    MMU.write(0xC000, <<0x80>>)
    assert Ex.decode(<<0x06>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x10>>}
    assert MMU.read(0xC000) == <<0x01>>
  end

  test "0x08.. RRC reg" do
    assert Ex.decode(<<0x08>>, %{@default | 0 => <<5>>, 6 => <<0>>}) == %{@rhs | 0 => <<130>>, 6 => <<16>>}
    assert Ex.decode(<<0x09>>, %{@default | 1 => <<0>>, 6 => <<0>>}) == %{@rhs | 1 => <<0>>, 6 => <<128>>}
    assert Ex.decode(<<0x0A>>, %{@default | 2 => <<128>>, 6 => <<0>>}) == %{@rhs | 2 => <<64>>, 6 => <<0>>}
    assert Ex.decode(<<0x0B>>, %{@default | 3 => <<0>>, 6 => <<16>>}) == %{@rhs | 3 => <<0>>, 6 => <<128>>}
    assert Ex.decode(<<0x0C>>, %{@default | 4 => <<128>>, 6 => <<16>>}) == %{@rhs | 4 => <<64>>, 6 => <<0>>}
    assert Ex.decode(<<0x0D>>, %{@default | 5 => <<255>>, 6 => <<16>>}) == %{@rhs | 5 => <<255>>, 6 => <<16>>}
    assert Ex.decode(<<0x0F>>, %{@default | 7 => <<254>>, 6 => <<64>>}) == %{@rhs | 7 => <<127>>, 6 => <<0>>}
  end

  test "0x0E - RRC (HL)" do
    MMU.write(0xC000, <<0x01>>)
    assert Ex.decode(<<0x0E>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x10>>}
    assert MMU.read(0xC000) == <<0x80>>
  end

  test "0x10.. RL reg" do
    assert Ex.decode(<<0x10>>, %{@default | 0 => <<5>>, 6 => <<0>>}) == %{@rhs | 0 => <<10>>, 6 => <<0>>}
    assert Ex.decode(<<0x11>>, %{@default | 1 => <<0>>, 6 => <<0>>}) == %{@rhs | 1 => <<0>>, 6 => <<128>>}
    assert Ex.decode(<<0x12>>, %{@default | 2 => <<128>>, 6 => <<0>>}) == %{@rhs | 2 => <<0>>, 6 => <<144>>}
    assert Ex.decode(<<0x13>>, %{@default | 3 => <<0>>, 6 => <<16>>}) == %{@rhs | 3 => <<1>>, 6 => <<0>>}
    assert Ex.decode(<<0x14>>, %{@default | 4 => <<128>>, 6 => <<16>>}) == %{@rhs | 4 => <<1>>, 6 => <<16>>}
    assert Ex.decode(<<0x15>>, %{@default | 5 => <<255>>, 6 => <<16>>}) == %{@rhs | 5 => <<255>>, 6 => <<16>>}
    assert Ex.decode(<<0x17>>, %{@default | 7 => <<255>>, 6 => <<0>>}) == %{@rhs | 7 => <<254>>, 6 => <<16>>}
  end

  test "0x16 - RL (HL)" do
    MMU.write(0xC000, <<0x80>>)
    assert Ex.decode(<<0x16>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x90>>}
    assert MMU.read(0xC000) == <<0x00>>
  end

  test "0x18.. RR reg" do
    assert Ex.decode(<<0x18>>, %{@default | 0 => <<5>>, 6 => <<0>>}) == %{@rhs | 0 => <<2>>, 6 => <<16>>}
    assert Ex.decode(<<0x19>>, %{@default | 1 => <<6>>, 6 => <<0>>}) == %{@rhs | 1 => <<3>>, 6 => <<0>>}
    assert Ex.decode(<<0x1A>>, %{@default | 2 => <<1>>, 6 => <<0>>}) == %{@rhs | 2 => <<0>>, 6 => <<144>>}
    assert Ex.decode(<<0x1B>>, %{@default | 3 => <<1>>, 6 => <<16>>}) == %{@rhs | 3 => <<128>>, 6 => <<16>>}
    assert Ex.decode(<<0x1C>>, %{@default | 4 => <<128>>, 6 => <<16>>}) == %{@rhs | 4 => <<192>>, 6 => <<0>>}
    assert Ex.decode(<<0x1D>>, %{@default | 5 => <<0>>, 6 => <<16>>}) == %{@rhs | 5 => <<128>>, 6 => <<0>>}
    assert Ex.decode(<<0x1F>>, %{@default | 7 => <<0>>, 6 => <<0>>}) == %{@rhs | 7 => <<0>>, 6 => <<128>>}
  end

  test "0x1E - RR (HL)" do
    MMU.write(0xC000, <<0x01>>)
    assert Ex.decode(<<0x1E>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x90>>}
    assert MMU.read(0xC000) == <<0x00>>
  end

  test "0x20.. SLA reg" do
    assert Ex.decode(<<0x20>>, %{@default | 0 => <<5>>, 6 => <<16>>}) == %{@rhs | 0 => <<10>>, 6 => <<0>>}
    assert Ex.decode(<<0x21>>, %{@default | 1 => <<0>>, 6 => <<0>>}) == %{@rhs | 1 => <<0>>, 6 => <<128>>}
    assert Ex.decode(<<0x22>>, %{@default | 2 => <<128>>, 6 => <<0>>}) == %{@rhs | 2 => <<0>>, 6 => <<144>>}
    assert Ex.decode(<<0x23>>, %{@default | 3 => <<0>>, 6 => <<16>>}) == %{@rhs | 3 => <<0>>, 6 => <<128>>}
    assert Ex.decode(<<0x24>>, %{@default | 4 => <<128>>, 6 => <<16>>}) == %{@rhs | 4 => <<0>>, 6 => <<144>>}
    assert Ex.decode(<<0x25>>, %{@default | 5 => <<255>>, 6 => <<16>>}) == %{@rhs | 5 => <<254>>, 6 => <<16>>}
    assert Ex.decode(<<0x27>>, %{@default | 7 => <<255>>, 6 => <<0>>}) == %{@rhs | 7 => <<254>>, 6 => <<16>>}
  end

  test "0x26 - SLA (HL)" do
    MMU.write(0xC000, <<0xFF>>)
    assert Ex.decode(<<0x26>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x10>>}
    assert MMU.read(0xC000) == <<0xFE>>
  end

  test "0x28.. SRA reg" do
    assert Ex.decode(<<0x28>>, %{@default | 0 => <<5>>, 6 => <<0>>}) == %{@rhs | 0 => <<2>>, 6 => <<16>>}
    assert Ex.decode(<<0x29>>, %{@default | 1 => <<6>>, 6 => <<0>>}) == %{@rhs | 1 => <<3>>, 6 => <<0>>}
    assert Ex.decode(<<0x2A>>, %{@default | 2 => <<1>>, 6 => <<0>>}) == %{@rhs | 2 => <<0>>, 6 => <<144>>}
    assert Ex.decode(<<0x2B>>, %{@default | 3 => <<1>>, 6 => <<16>>}) == %{@rhs | 3 => <<0>>, 6 => <<144>>}
    assert Ex.decode(<<0x2C>>, %{@default | 4 => <<128>>, 6 => <<16>>}) == %{@rhs | 4 => <<192>>, 6 => <<0>>}
    assert Ex.decode(<<0x2D>>, %{@default | 5 => <<127>>, 6 => <<16>>}) == %{@rhs | 5 => <<63>>, 6 => <<16>>}
    assert Ex.decode(<<0x2F>>, %{@default | 7 => <<255>>, 6 => <<128>>}) == %{@rhs | 7 => <<255>>, 6 => <<16>>}
  end

  test "0x2E - SRA (HL)" do
    MMU.write(0xC000, <<0x81>>)
    assert Ex.decode(<<0x2E>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x10>>}
    assert MMU.read(0xC000) == <<0xC0>>
  end

  test "0x30.. SWAP reg" do
    assert Ex.decode(<<0x30>>, %{@default | 0 => <<5>>}) == %{@rhs | 0 => <<80>>, 6 => <<0>>}
    assert Ex.decode(<<0x31>>, %{@default | 1 => <<0>>}) == %{@rhs | 1 => <<0>>, 6 => <<128>>}
    assert Ex.decode(<<0x32>>, %{@default | 2 => <<128>>}) == %{@rhs | 2 => <<8>>, 6 => <<0>>}
    assert Ex.decode(<<0x33>>, %{@default | 3 => <<60>>}) == %{@rhs | 3 => <<195>>, 6 => <<0>>}
    assert Ex.decode(<<0x34>>, %{@default | 4 => <<127>>}) == %{@rhs | 4 => <<247>>, 6 => <<0>>}
    assert Ex.decode(<<0x35>>, %{@default | 5 => <<165>>}) == %{@rhs | 5 => <<90>>, 6 => <<0>>}
    assert Ex.decode(<<0x37>>, %{@default | 7 => <<253>>}) == %{@rhs | 7 => <<223>>, 6 => <<0>>}
  end

  test "0x36 - SWAP (HL)" do
    MMU.write(0xC000, <<0x81>>)
    assert Ex.decode(<<0x36>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x00>>}
    assert MMU.read(0xC000) == <<0x18>>
  end

  test "0x38.. SRL reg" do
    assert Ex.decode(<<0x38>>, %{@default | 0 => <<5>>, 6 => <<0>>}) == %{@rhs | 0 => <<2>>, 6 => <<16>>}
    assert Ex.decode(<<0x39>>, %{@default | 1 => <<6>>, 6 => <<0>>}) == %{@rhs | 1 => <<3>>, 6 => <<0>>}
    assert Ex.decode(<<0x3A>>, %{@default | 2 => <<1>>, 6 => <<0>>}) == %{@rhs | 2 => <<0>>, 6 => <<144>>}
    assert Ex.decode(<<0x3B>>, %{@default | 3 => <<1>>, 6 => <<16>>}) == %{@rhs | 3 => <<0>>, 6 => <<144>>}
    assert Ex.decode(<<0x3C>>, %{@default | 4 => <<128>>, 6 => <<16>>}) == %{@rhs | 4 => <<64>>, 6 => <<0>>}
    assert Ex.decode(<<0x3D>>, %{@default | 5 => <<129>>, 6 => <<128>>}) == %{@rhs | 5 => <<64>>, 6 => <<16>>}
    assert Ex.decode(<<0x3F>>, %{@default | 7 => <<255>>, 6 => <<128>>}) == %{@rhs | 7 => <<127>>, 6 => <<16>>}
  end

  test "0x3E - SRL (HL)" do
    MMU.write(0xC000, <<0x81>>)
    assert Ex.decode(<<0x3E>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x10>>}
    assert MMU.read(0xC000) == <<0x40>>
  end

  test "0x40.. Bit n, reg" do
    # 0
    assert Ex.decode(<<0x40>>, %{@default | 0 => <<0>>, 6 => <<0>>}) == %{@rhs | 0 => <<0>>, 6 => <<160>>}
    assert Ex.decode(<<0x41>>, %{@default | 1 => <<1>>, 6 => <<16>>}) == %{@rhs | 1 => <<1>>, 6 => <<48>>}
    assert Ex.decode(<<0x42>>, %{@default | 2 => <<2>>, 6 => <<32>>}) == %{@rhs | 2 => <<2>>, 6 => <<160>>}
    assert Ex.decode(<<0x43>>, %{@default | 3 => <<3>>, 6 => <<128>>}) == %{@rhs | 3 => <<3>>, 6 => <<32>>}
    assert Ex.decode(<<0x44>>, %{@default | 4 => <<4>>, 6 => <<0>>}) == %{@rhs | 4 => <<4>>, 6 => <<160>>}
    assert Ex.decode(<<0x45>>, %{@default | 5 => <<5>>, 6 => <<16>>}) == %{@rhs | 5 => <<5>>, 6 => <<48>>}
    assert Ex.decode(<<0x47>>, %{@default | 7 => <<7>>, 6 => <<128>>}) == %{@rhs | 7 => <<7>>, 6 => <<32>>}
    # 1
    assert Ex.decode(<<0x48>>, %{@default | 0 => <<8>>, 6 => <<144>>}) == %{@rhs | 0 => <<8>>, 6 => <<176>>}
    assert Ex.decode(<<0x49>>, %{@default | 1 => <<9>>, 6 => <<192>>}) == %{@rhs | 1 => <<9>>, 6 => <<160>>}
    assert Ex.decode(<<0x4A>>, %{@default | 2 => <<10>>, 6 => <<0>>}) == %{@rhs | 2 => <<10>>, 6 => <<32>>}
    assert Ex.decode(<<0x4B>>, %{@default | 3 => <<11>>, 6 => <<48>>}) == %{@rhs | 3 => <<11>>, 6 => <<48>>}
    assert Ex.decode(<<0x4C>>, %{@default | 4 => <<12>>, 6 => <<160>>}) == %{@rhs | 4 => <<12>>, 6 => <<160>>}
    assert Ex.decode(<<0x4D>>, %{@default | 5 => <<13>>, 6 => <<0>>}) == %{@rhs | 5 => <<13>>, 6 => <<160>>}
    assert Ex.decode(<<0x4F>>, %{@default | 7 => <<15>>, 6 => <<16>>}) == %{@rhs | 7 => <<15>>, 6 => <<48>>}
    # 2
    assert Ex.decode(<<0x50>>, %{@default | 0 => <<16>>, 6 => <<32>>}) == %{@rhs | 0 => <<16>>, 6 => <<160>>}
    assert Ex.decode(<<0x51>>, %{@default | 1 => <<17>>, 6 => <<128>>}) == %{@rhs | 1 => <<17>>, 6 => <<160>>}
    assert Ex.decode(<<0x52>>, %{@default | 2 => <<18>>, 6 => <<0>>}) == %{@rhs | 2 => <<18>>, 6 => <<160>>}
    assert Ex.decode(<<0x53>>, %{@default | 3 => <<19>>, 6 => <<16>>}) == %{@rhs | 3 => <<19>>, 6 => <<176>>}
    assert Ex.decode(<<0x54>>, %{@default | 4 => <<20>>, 6 => <<128>>}) == %{@rhs | 4 => <<20>>, 6 => <<32>>}
    assert Ex.decode(<<0x55>>, %{@default | 5 => <<21>>, 6 => <<144>>}) == %{@rhs | 5 => <<21>>, 6 => <<48>>}
    assert Ex.decode(<<0x57>>, %{@default | 7 => <<23>>, 6 => <<192>>}) == %{@rhs | 7 => <<23>>, 6 => <<32>>}
    # 3
    assert Ex.decode(<<0x58>>, %{@default | 0 => <<24>>, 6 => <<0>>}) == %{@rhs | 0 => <<24>>, 6 => <<32>>}
    assert Ex.decode(<<0x59>>, %{@default | 1 => <<25>>, 6 => <<48>>}) == %{@rhs | 1 => <<25>>, 6 => <<48>>}
    assert Ex.decode(<<0x5A>>, %{@default | 2 => <<26>>, 6 => <<160>>}) == %{@rhs | 2 => <<26>>, 6 => <<32>>}
    assert Ex.decode(<<0x5B>>, %{@default | 3 => <<27>>, 6 => <<0>>}) == %{@rhs | 3 => <<27>>, 6 => <<32>>}
    assert Ex.decode(<<0x5C>>, %{@default | 4 => <<28>>, 6 => <<16>>}) == %{@rhs | 4 => <<28>>, 6 => <<48>>}
    assert Ex.decode(<<0x5D>>, %{@default | 5 => <<29>>, 6 => <<32>>}) == %{@rhs | 5 => <<29>>, 6 => <<32>>}
    assert Ex.decode(<<0x5F>>, %{@default | 7 => <<31>>, 6 => <<128>>}) == %{@rhs | 7 => <<31>>, 6 => <<32>>}
    # 4
    assert Ex.decode(<<0x60>>, %{@default | 0 => <<32>>, 6 => <<0>>}) == %{@rhs | 0 => <<32>>, 6 => <<160>>}
    assert Ex.decode(<<0x61>>, %{@default | 1 => <<33>>, 6 => <<16>>}) == %{@rhs | 1 => <<33>>, 6 => <<176>>}
    assert Ex.decode(<<0x62>>, %{@default | 2 => <<34>>, 6 => <<128>>}) == %{@rhs | 2 => <<34>>, 6 => <<160>>}
    assert Ex.decode(<<0x63>>, %{@default | 3 => <<35>>, 6 => <<144>>}) == %{@rhs | 3 => <<35>>, 6 => <<176>>}
    assert Ex.decode(<<0x64>>, %{@default | 4 => <<36>>, 6 => <<192>>}) == %{@rhs | 4 => <<36>>, 6 => <<160>>}
    assert Ex.decode(<<0x65>>, %{@default | 5 => <<37>>, 6 => <<0>>}) == %{@rhs | 5 => <<37>>, 6 => <<160>>}
    assert Ex.decode(<<0x67>>, %{@default | 7 => <<39>>, 6 => <<48>>}) == %{@rhs | 7 => <<39>>, 6 => <<176>>}
    # 5
    assert Ex.decode(<<0x68>>, %{@default | 0 => <<40>>, 6 => <<160>>}) == %{@rhs | 0 => <<40>>, 6 => <<32>>}
    assert Ex.decode(<<0x69>>, %{@default | 1 => <<41>>, 6 => <<0>>}) == %{@rhs | 1 => <<41>>, 6 => <<32>>}
    assert Ex.decode(<<0x6A>>, %{@default | 2 => <<42>>, 6 => <<16>>}) == %{@rhs | 2 => <<42>>, 6 => <<48>>}
    assert Ex.decode(<<0x6B>>, %{@default | 3 => <<43>>, 6 => <<32>>}) == %{@rhs | 3 => <<43>>, 6 => <<32>>}
    assert Ex.decode(<<0x6C>>, %{@default | 4 => <<44>>, 6 => <<48>>}) == %{@rhs | 4 => <<44>>, 6 => <<48>>}
    assert Ex.decode(<<0x6D>>, %{@default | 5 => <<45>>, 6 => <<144>>}) == %{@rhs | 5 => <<45>>, 6 => <<48>>}
    assert Ex.decode(<<0x6F>>, %{@default | 7 => <<47>>, 6 => <<128>>}) == %{@rhs | 7 => <<47>>, 6 => <<32>>}
    # 6
    assert Ex.decode(<<0x70>>, %{@default | 0 => <<48>>, 6 => <<192>>}) == %{@rhs | 0 => <<48>>, 6 => <<160>>}
    assert Ex.decode(<<0x71>>, %{@default | 1 => <<49>>, 6 => <<0>>}) == %{@rhs | 1 => <<49>>, 6 => <<160>>}
    assert Ex.decode(<<0x72>>, %{@default | 2 => <<50>>, 6 => <<16>>}) == %{@rhs | 2 => <<50>>, 6 => <<176>>}
    assert Ex.decode(<<0x73>>, %{@default | 3 => <<51>>, 6 => <<32>>}) == %{@rhs | 3 => <<51>>, 6 => <<160>>}
    assert Ex.decode(<<0x74>>, %{@default | 4 => <<52>>, 6 => <<240>>}) == %{@rhs | 4 => <<52>>, 6 => <<176>>}
    assert Ex.decode(<<0x75>>, %{@default | 5 => <<53>>, 6 => <<224>>}) == %{@rhs | 5 => <<53>>, 6 => <<160>>}
    assert Ex.decode(<<0x77>>, %{@default | 7 => <<55>>, 6 => <<192>>}) == %{@rhs | 7 => <<55>>, 6 => <<160>>}
    # 7
    assert Ex.decode(<<0x78>>, %{@default | 0 => <<128>>, 6 => <<16>>}) == %{@rhs | 0 => <<128>>, 6 => <<48>>}
    assert Ex.decode(<<0x79>>, %{@default | 1 => <<127>>, 6 => <<0>>}) == %{@rhs | 1 => <<127>>, 6 => <<160>>}
    assert Ex.decode(<<0x7A>>, %{@default | 2 => <<255>>, 6 => <<128>>}) == %{@rhs | 2 => <<255>>, 6 => <<32>>}
    assert Ex.decode(<<0x7B>>, %{@default | 3 => <<0>>, 6 => <<48>>}) == %{@rhs | 3 => <<0>>, 6 => <<176>>}
    assert Ex.decode(<<0x7C>>, %{@default | 4 => <<200>>, 6 => <<64>>}) == %{@rhs | 4 => <<200>>, 6 => <<32>>}
    assert Ex.decode(<<0x7D>>, %{@default | 5 => <<129>>, 6 => <<96>>}) == %{@rhs | 5 => <<129>>, 6 => <<32>>}
    assert Ex.decode(<<0x7F>>, %{@default | 7 => <<67>>, 6 => <<80>>}) == %{@rhs | 7 => <<67>>, 6 => <<176>>}
  end

  test "0x40.. BIT n, (HL)" do
    MMU.write(0xC000, <<0xAA>>)
    # 0
    assert Ex.decode(<<0x46>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x40>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0xA0>>}
    # 1
    assert Ex.decode(<<0x4E>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x40>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x20>>}
    # 2
    assert Ex.decode(<<0x56>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x40>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0xA0>>}
    # 3
    assert Ex.decode(<<0x5E>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x40>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x20>>}
    # 4
    assert Ex.decode(<<0x66>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x40>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0xA0>>}
    # 5
    assert Ex.decode(<<0x6E>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x40>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x20>>}
    # 6
    assert Ex.decode(<<0x76>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x40>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0xA0>>}
    # 7
    assert Ex.decode(<<0x7E>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x40>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>, 6 => <<0x20>>}
  end

  test "0x80.. RES pos, reg" do
    # 0
    assert Ex.decode(<<0x80>>, %{@default | 0 => <<0>>}) == %{@rhs | 0 => <<0>>}
    assert Ex.decode(<<0x81>>, %{@default | 1 => <<1>>}) == %{@rhs | 1 => <<0>>}
    assert Ex.decode(<<0x82>>, %{@default | 2 => <<2>>}) == %{@rhs | 2 => <<2>>}
    assert Ex.decode(<<0x83>>, %{@default | 3 => <<3>>}) == %{@rhs | 3 => <<2>>}
    assert Ex.decode(<<0x84>>, %{@default | 4 => <<4>>}) == %{@rhs | 4 => <<4>>}
    assert Ex.decode(<<0x85>>, %{@default | 5 => <<5>>}) == %{@rhs | 5 => <<4>>}
    assert Ex.decode(<<0x87>>, %{@default | 7 => <<7>>}) == %{@rhs | 7 => <<6>>}
    # 1
    assert Ex.decode(<<0x88>>, %{@default | 0 => <<8>>}) == %{@rhs | 0 => <<8>>}
    assert Ex.decode(<<0x89>>, %{@default | 1 => <<9>>}) == %{@rhs | 1 => <<9>>}
    assert Ex.decode(<<0x8A>>, %{@default | 2 => <<10>>}) == %{@rhs | 2 => <<8>>}
    assert Ex.decode(<<0x8B>>, %{@default | 3 => <<11>>}) == %{@rhs | 3 => <<9>>}
    assert Ex.decode(<<0x8C>>, %{@default | 4 => <<12>>}) == %{@rhs | 4 => <<12>>}
    assert Ex.decode(<<0x8D>>, %{@default | 5 => <<13>>}) == %{@rhs | 5 => <<13>>}
    assert Ex.decode(<<0x8F>>, %{@default | 7 => <<15>>}) == %{@rhs | 7 => <<13>>}
    # 2
    assert Ex.decode(<<0x90>>, %{@default | 0 => <<16>>}) == %{@rhs | 0 => <<16>>}
    assert Ex.decode(<<0x91>>, %{@default | 1 => <<17>>}) == %{@rhs | 1 => <<17>>}
    assert Ex.decode(<<0x92>>, %{@default | 2 => <<18>>}) == %{@rhs | 2 => <<18>>}
    assert Ex.decode(<<0x93>>, %{@default | 3 => <<19>>}) == %{@rhs | 3 => <<19>>}
    assert Ex.decode(<<0x94>>, %{@default | 4 => <<20>>}) == %{@rhs | 4 => <<16>>}
    assert Ex.decode(<<0x95>>, %{@default | 5 => <<21>>}) == %{@rhs | 5 => <<17>>}
    assert Ex.decode(<<0x97>>, %{@default | 7 => <<23>>}) == %{@rhs | 7 => <<19>>}
    # 3
    assert Ex.decode(<<0x98>>, %{@default | 0 => <<104>>}) == %{@rhs | 0 => <<96>>}
    assert Ex.decode(<<0x99>>, %{@default | 1 => <<105>>}) == %{@rhs | 1 => <<97>>}
    assert Ex.decode(<<0x9A>>, %{@default | 2 => <<106>>}) == %{@rhs | 2 => <<98>>}
    assert Ex.decode(<<0x9B>>, %{@default | 3 => <<107>>}) == %{@rhs | 3 => <<99>>}
    assert Ex.decode(<<0x9C>>, %{@default | 4 => <<108>>}) == %{@rhs | 4 => <<100>>}
    assert Ex.decode(<<0x9D>>, %{@default | 5 => <<109>>}) == %{@rhs | 5 => <<101>>}
    assert Ex.decode(<<0x9F>>, %{@default | 7 => <<111>>}) == %{@rhs | 7 => <<103>>}
    # 4
    assert Ex.decode(<<0xA0>>, %{@default | 0 => <<32>>}) == %{@rhs | 0 => <<32>>}
    assert Ex.decode(<<0xA1>>, %{@default | 1 => <<33>>}) == %{@rhs | 1 => <<33>>}
    assert Ex.decode(<<0xA2>>, %{@default | 2 => <<34>>}) == %{@rhs | 2 => <<34>>}
    assert Ex.decode(<<0xA3>>, %{@default | 3 => <<35>>}) == %{@rhs | 3 => <<35>>}
    assert Ex.decode(<<0xA4>>, %{@default | 4 => <<36>>}) == %{@rhs | 4 => <<36>>}
    assert Ex.decode(<<0xA5>>, %{@default | 5 => <<37>>}) == %{@rhs | 5 => <<37>>}
    assert Ex.decode(<<0xA7>>, %{@default | 7 => <<39>>}) == %{@rhs | 7 => <<39>>}
    # 5
    assert Ex.decode(<<0xA8>>, %{@default | 0 => <<160>>}) == %{@rhs | 0 => <<128>>}
    assert Ex.decode(<<0xA9>>, %{@default | 1 => <<161>>}) == %{@rhs | 1 => <<129>>}
    assert Ex.decode(<<0xAA>>, %{@default | 2 => <<130>>}) == %{@rhs | 2 => <<130>>}
    assert Ex.decode(<<0xAB>>, %{@default | 3 => <<162>>}) == %{@rhs | 3 => <<130>>}
    assert Ex.decode(<<0xAC>>, %{@default | 4 => <<163>>}) == %{@rhs | 4 => <<131>>}
    assert Ex.decode(<<0xAD>>, %{@default | 5 => <<164>>}) == %{@rhs | 5 => <<132>>}
    assert Ex.decode(<<0xAF>>, %{@default | 7 => <<166>>}) == %{@rhs | 7 => <<134>>}
    # 6
    assert Ex.decode(<<0xB0>>, %{@default | 0 => <<200>>}) == %{@rhs | 0 => <<136>>}
    assert Ex.decode(<<0xB1>>, %{@default | 1 => <<201>>}) == %{@rhs | 1 => <<137>>}
    assert Ex.decode(<<0xB2>>, %{@default | 2 => <<202>>}) == %{@rhs | 2 => <<138>>}
    assert Ex.decode(<<0xB3>>, %{@default | 3 => <<130>>}) == %{@rhs | 3 => <<130>>}
    assert Ex.decode(<<0xB4>>, %{@default | 4 => <<204>>}) == %{@rhs | 4 => <<140>>}
    assert Ex.decode(<<0xB5>>, %{@default | 5 => <<205>>}) == %{@rhs | 5 => <<141>>}
    assert Ex.decode(<<0xB7>>, %{@default | 7 => <<207>>}) == %{@rhs | 7 => <<143>>}
    # 7
    assert Ex.decode(<<0xB8>>, %{@default | 0 => <<128>>}) == %{@rhs | 0 => <<0>>}
    assert Ex.decode(<<0xB9>>, %{@default | 1 => <<127>>}) == %{@rhs | 1 => <<127>>}
    assert Ex.decode(<<0xBA>>, %{@default | 2 => <<255>>}) == %{@rhs | 2 => <<127>>}
    assert Ex.decode(<<0xBB>>, %{@default | 3 => <<0>>}) == %{@rhs | 3 => <<0>>}
    assert Ex.decode(<<0xBC>>, %{@default | 4 => <<200>>}) == %{@rhs | 4 => <<72>>}
    assert Ex.decode(<<0xBD>>, %{@default | 5 => <<129>>}) == %{@rhs | 5 => <<1>>}
    assert Ex.decode(<<0xBF>>, %{@default | 7 => <<67>>}) == %{@rhs | 7 => <<67>>}
  end

  test "0x80.. RES n, (HL)" do
    # 0
    MMU.write(0xC000, <<0xFF>>)
    assert Ex.decode(<<0x86>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>}
    assert MMU.read(0xC000) == <<0xFE>>
    # 1
    MMU.write(0xC000, <<0xFF>>)
    assert Ex.decode(<<0x8E>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>}
    assert MMU.read(0xC000) == <<0xFD>>
    # 2
    MMU.write(0xC000, <<0xFF>>)
    assert Ex.decode(<<0x96>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>}
    assert MMU.read(0xC000) == <<0xFB>>
    # 3
    MMU.write(0xC000, <<0xFF>>)
    assert Ex.decode(<<0x9E>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>}
    assert MMU.read(0xC000) == <<0xF7>>
    # 4
    MMU.write(0xC000, <<0xFF>>)
    assert Ex.decode(<<0xA6>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>}
    assert MMU.read(0xC000) == <<0xEF>>
    # 5
    MMU.write(0xC000, <<0xFF>>)
    assert Ex.decode(<<0xAE>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>}
    assert MMU.read(0xC000) == <<0xDF>>
    # 6
    MMU.write(0xC000, <<0xFF>>)
    assert Ex.decode(<<0xB6>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>}
    assert MMU.read(0xC000) == <<0xBF>>
    # 7
    MMU.write(0xC000, <<0xFF>>)
    assert Ex.decode(<<0xBE>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>}
    assert MMU.read(0xC000) == <<0x7F>>
  end

  test "0xC0.. SET pos, reg" do
    # 0
    assert Ex.decode(<<0xC0>>, %{@default | 0 => <<0>>}) == %{@rhs | 0 => <<1>>}
    assert Ex.decode(<<0xC1>>, %{@default | 1 => <<1>>}) == %{@rhs | 1 => <<1>>}
    assert Ex.decode(<<0xC2>>, %{@default | 2 => <<2>>}) == %{@rhs | 2 => <<3>>}
    assert Ex.decode(<<0xC3>>, %{@default | 3 => <<3>>}) == %{@rhs | 3 => <<3>>}
    assert Ex.decode(<<0xC4>>, %{@default | 4 => <<4>>}) == %{@rhs | 4 => <<5>>}
    assert Ex.decode(<<0xC5>>, %{@default | 5 => <<5>>}) == %{@rhs | 5 => <<5>>}
    assert Ex.decode(<<0xC7>>, %{@default | 7 => <<7>>}) == %{@rhs | 7 => <<7>>}
    # 1
    assert Ex.decode(<<0xC8>>, %{@default | 0 => <<8>>}) == %{@rhs | 0 => <<10>>}
    assert Ex.decode(<<0xC9>>, %{@default | 1 => <<9>>}) == %{@rhs | 1 => <<11>>}
    assert Ex.decode(<<0xCA>>, %{@default | 2 => <<10>>}) == %{@rhs | 2 => <<10>>}
    assert Ex.decode(<<0xCB>>, %{@default | 3 => <<11>>}) == %{@rhs | 3 => <<11>>}
    assert Ex.decode(<<0xCC>>, %{@default | 4 => <<12>>}) == %{@rhs | 4 => <<14>>}
    assert Ex.decode(<<0xCD>>, %{@default | 5 => <<13>>}) == %{@rhs | 5 => <<15>>}
    assert Ex.decode(<<0xCF>>, %{@default | 7 => <<15>>}) == %{@rhs | 7 => <<15>>}
    # 2
    assert Ex.decode(<<0xD0>>, %{@default | 0 => <<16>>}) == %{@rhs | 0 => <<20>>}
    assert Ex.decode(<<0xD1>>, %{@default | 1 => <<17>>}) == %{@rhs | 1 => <<21>>}
    assert Ex.decode(<<0xD2>>, %{@default | 2 => <<18>>}) == %{@rhs | 2 => <<22>>}
    assert Ex.decode(<<0xD3>>, %{@default | 3 => <<19>>}) == %{@rhs | 3 => <<23>>}
    assert Ex.decode(<<0xD4>>, %{@default | 4 => <<20>>}) == %{@rhs | 4 => <<20>>}
    assert Ex.decode(<<0xD5>>, %{@default | 5 => <<21>>}) == %{@rhs | 5 => <<21>>}
    assert Ex.decode(<<0xD7>>, %{@default | 7 => <<23>>}) == %{@rhs | 7 => <<23>>}
    # 3
    assert Ex.decode(<<0xD8>>, %{@default | 0 => <<70>>}) == %{@rhs | 0 => <<78>>}
    assert Ex.decode(<<0xD9>>, %{@default | 1 => <<71>>}) == %{@rhs | 1 => <<79>>}
    assert Ex.decode(<<0xDA>>, %{@default | 2 => <<72>>}) == %{@rhs | 2 => <<72>>}
    assert Ex.decode(<<0xDB>>, %{@default | 3 => <<73>>}) == %{@rhs | 3 => <<73>>}
    assert Ex.decode(<<0xDC>>, %{@default | 4 => <<80>>}) == %{@rhs | 4 => <<88>>}
    assert Ex.decode(<<0xDD>>, %{@default | 5 => <<81>>}) == %{@rhs | 5 => <<89>>}
    assert Ex.decode(<<0xDF>>, %{@default | 7 => <<82>>}) == %{@rhs | 7 => <<90>>}
    # 4
    assert Ex.decode(<<0xE0>>, %{@default | 0 => <<32>>}) == %{@rhs | 0 => <<48>>}
    assert Ex.decode(<<0xE1>>, %{@default | 1 => <<33>>}) == %{@rhs | 1 => <<49>>}
    assert Ex.decode(<<0xE2>>, %{@default | 2 => <<34>>}) == %{@rhs | 2 => <<50>>}
    assert Ex.decode(<<0xE3>>, %{@default | 3 => <<35>>}) == %{@rhs | 3 => <<51>>}
    assert Ex.decode(<<0xE4>>, %{@default | 4 => <<36>>}) == %{@rhs | 4 => <<52>>}
    assert Ex.decode(<<0xE5>>, %{@default | 5 => <<37>>}) == %{@rhs | 5 => <<53>>}
    assert Ex.decode(<<0xE7>>, %{@default | 7 => <<39>>}) == %{@rhs | 7 => <<55>>}
    # 5
    assert Ex.decode(<<0xE8>>, %{@default | 0 => <<0>>}) == %{@rhs | 0 => <<32>>}
    assert Ex.decode(<<0xE9>>, %{@default | 1 => <<1>>}) == %{@rhs | 1 => <<33>>}
    assert Ex.decode(<<0xEA>>, %{@default | 2 => <<2>>}) == %{@rhs | 2 => <<34>>}
    assert Ex.decode(<<0xEB>>, %{@default | 3 => <<3>>}) == %{@rhs | 3 => <<35>>}
    assert Ex.decode(<<0xEC>>, %{@default | 4 => <<4>>}) == %{@rhs | 4 => <<36>>}
    assert Ex.decode(<<0xED>>, %{@default | 5 => <<5>>}) == %{@rhs | 5 => <<37>>}
    assert Ex.decode(<<0xEF>>, %{@default | 7 => <<7>>}) == %{@rhs | 7 => <<39>>}
    # 6
    assert Ex.decode(<<0xF0>>, %{@default | 0 => <<48>>}) == %{@rhs | 0 => <<112>>}
    assert Ex.decode(<<0xF1>>, %{@default | 1 => <<49>>}) == %{@rhs | 1 => <<113>>}
    assert Ex.decode(<<0xF2>>, %{@default | 2 => <<50>>}) == %{@rhs | 2 => <<114>>}
    assert Ex.decode(<<0xF3>>, %{@default | 3 => <<51>>}) == %{@rhs | 3 => <<115>>}
    assert Ex.decode(<<0xF4>>, %{@default | 4 => <<52>>}) == %{@rhs | 4 => <<116>>}
    assert Ex.decode(<<0xF5>>, %{@default | 5 => <<53>>}) == %{@rhs | 5 => <<117>>}
    assert Ex.decode(<<0xF7>>, %{@default | 7 => <<55>>}) == %{@rhs | 7 => <<119>>}
    # 7
    assert Ex.decode(<<0xF8>>, %{@default | 0 => <<128>>}) == %{@rhs | 0 => <<128>>}
    assert Ex.decode(<<0xF9>>, %{@default | 1 => <<127>>}) == %{@rhs | 1 => <<255>>}
    assert Ex.decode(<<0xFA>>, %{@default | 2 => <<255>>}) == %{@rhs | 2 => <<255>>}
    assert Ex.decode(<<0xFB>>, %{@default | 3 => <<0>>}) == %{@rhs | 3 => <<128>>}
    assert Ex.decode(<<0xFC>>, %{@default | 4 => <<200>>}) == %{@rhs | 4 => <<200>>}
    assert Ex.decode(<<0xFD>>, %{@default | 5 => <<129>>}) == %{@rhs | 5 => <<129>>}
    assert Ex.decode(<<0xFF>>, %{@default | 7 => <<67>>}) == %{@rhs | 7 => <<195>>}
  end

  test "0xC0.. RES n, (HL)" do
    # 0
    MMU.write(0xC000, <<0x00>>)
    assert Ex.decode(<<0xC6>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>}
    assert MMU.read(0xC000) == <<0x01>>
    # 1
    MMU.write(0xC000, <<0x00>>)
    assert Ex.decode(<<0xCE>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>}
    assert MMU.read(0xC000) == <<0x02>>
    # 2
    MMU.write(0xC000, <<0x00>>)
    assert Ex.decode(<<0xD6>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>}
    assert MMU.read(0xC000) == <<0x04>>
    # 3
    MMU.write(0xC000, <<0x00>>)
    assert Ex.decode(<<0xDE>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>}
    assert MMU.read(0xC000) == <<0x08>>
    # 4
    MMU.write(0xC000, <<0x00>>)
    assert Ex.decode(<<0xE6>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>}
    assert MMU.read(0xC000) == <<0x10>>
    # 5
    MMU.write(0xC000, <<0x00>>)
    assert Ex.decode(<<0xEE>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>}
    assert MMU.read(0xC000) == <<0x20>>
    # 6
    MMU.write(0xC000, <<0x00>>)
    assert Ex.decode(<<0xF6>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>}
    assert MMU.read(0xC000) == <<0x40>>
    # 7
    MMU.write(0xC000, <<0x00>>)
    assert Ex.decode(<<0xFE>>, %{@default | 4 => <<0xC0>>, 5 => <<0x00>>}) == %{@rhs16 | 4 => <<0xC0>>, 5 => <<0x00>>}
    assert MMU.read(0xC000) == <<0x80>>
  end
end
