defmodule GameKunRAMTest do
  use ExUnit.Case
  doctest GameKun.RAM

  setup do
    ram = start_supervised!({GameKun.RAM, nil})
    %{ram: ram}
  end

  test "RAM Read" do
    assert GameKun.RAM.read(0xC000) == <<0x00>>
    assert GameKun.RAM.read(0xFF40) == <<0x91>>
    # MMU Test
    assert GameKun.MMU.read(0xC000) == <<0x00>>
    assert GameKun.MMU.read(0xFF40) == <<0x91>>
  end

  test "RAM Write" do
    assert GameKun.RAM.read(0xC101) == <<0x00>>
    GameKun.RAM.write(0xC101, <<0xFF>>)
    assert GameKun.RAM.read(0xC101) == <<0xFF>>

    assert GameKun.MMU.read(0xC101) == <<0xFF>>
    GameKun.MMU.write(0xC101, <<0x00>>)
    assert GameKun.MMU.read(0xC101) == <<0x00>>
  end

  test "Ram Banking" do
    assert GameKun.RAM.read(0xFF70) == <<0x01>>
    GameKun.RAM.write(0xFF70, <<0x00>>)
    assert GameKun.RAM.read(0xFF70) == <<0x01>>

    GameKun.RAM.write(0xD001, <<0xFF>>)
    assert GameKun.RAM.read(0xD001) == <<0xFF>>
    GameKun.RAM.write(0xFF70, <<0x02>>)
    assert GameKun.RAM.read(0xD002) != <<0xFF>>
    assert GameKun.RAM.read(0xD002) == <<0x00>>
    GameKun.RAM.write(0xFF70, <<0x03>>)
    assert GameKun.RAM.read(0xD003) != <<0xFF>>
    assert GameKun.RAM.read(0xD003) == <<0x00>>
    GameKun.RAM.write(0xFF70, <<0x04>>)
    assert GameKun.RAM.read(0xD004) != <<0xFF>>
    assert GameKun.RAM.read(0xD004) == <<0x00>>
    GameKun.RAM.write(0xFF70, <<0x05>>)
    assert GameKun.RAM.read(0xD005) != <<0xFF>>
    assert GameKun.RAM.read(0xD005) == <<0x00>>
    GameKun.RAM.write(0xFF70, <<0x06>>)
    assert GameKun.RAM.read(0xD006) != <<0xFF>>
    assert GameKun.RAM.read(0xD006) == <<0x00>>
    GameKun.RAM.write(0xFF70, <<0x07>>)
    assert GameKun.RAM.read(0xD007) != <<0xFF>>
    assert GameKun.RAM.read(0xD007) == <<0x00>>
    assert GameKun.RAM.read(0xDFFF) == <<0x00>>
  end
end
