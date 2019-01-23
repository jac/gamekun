defmodule GameKunRAMTest do
  use ExUnit.Case
  doctest GameKun.RAM
  alias GameKun.RAM
  alias GameKun.MMU

  setup do
    ram = start_supervised!({RAM, nil})
    %{ram: ram}
  end

  test "RAM Read" do
    assert RAM.read(0xC000) == <<0x00>>
    assert RAM.read(0xFF40) == <<0x91>>
    # MMU Test
    assert MMU.read(0xC000) == <<0x00>>
    assert MMU.read(0xFF40) == <<0x91>>
  end

  test "RAM Write" do
    assert RAM.read(0xC101) == <<0x00>>
    RAM.write(0xC101, <<0xFF>>)
    assert RAM.read(0xC101) == <<0xFF>>

    assert MMU.read(0xC101) == <<0xFF>>
    MMU.write(0xC101, <<0x00>>)
    assert MMU.read(0xC101) == <<0x00>>
  end

  test "Ram Banking" do
    assert RAM.read(0xFF70) == <<0x01>>
    RAM.write(0xFF70, <<0x00>>)
    assert RAM.read(0xFF70) == <<0x01>>

    RAM.write(0xD001, <<0xFF>>)
    assert RAM.read(0xD001) == <<0xFF>>
    RAM.write(0xFF70, <<0x02>>)
    assert RAM.read(0xD002) != <<0xFF>>
    assert RAM.read(0xD002) == <<0x00>>
    RAM.write(0xFF70, <<0x03>>)
    assert RAM.read(0xD003) != <<0xFF>>
    assert RAM.read(0xD003) == <<0x00>>
    RAM.write(0xFF70, <<0x04>>)
    assert RAM.read(0xD004) != <<0xFF>>
    assert RAM.read(0xD004) == <<0x00>>
    RAM.write(0xFF70, <<0x05>>)
    assert RAM.read(0xD005) != <<0xFF>>
    assert RAM.read(0xD005) == <<0x00>>
    RAM.write(0xFF70, <<0x06>>)
    assert RAM.read(0xD006) != <<0xFF>>
    assert RAM.read(0xD006) == <<0x00>>
    RAM.write(0xFF70, <<0x07>>)
    assert RAM.read(0xD007) != <<0xFF>>
    assert RAM.read(0xD007) == <<0x00>>
    assert RAM.read(0xDFFF) == <<0x00>>
  end
end
