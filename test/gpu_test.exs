defmodule GameKunGPUTest do
  use ExUnit.Case
  doctest GameKun.GPU

  setup do
    gpu = start_supervised!({GameKun.GPU, nil})
    ram = start_supervised!({GameKun.RAM, nil})
    %{gpu: gpu, ram: ram}
  end

  test "VRAM Read" do
    assert GameKun.GPU.read(0x8000) == <<0x00>>
    assert GameKun.GPU.read(0x9FFF) == <<0x00>>

    assert GameKun.MMU.read(0x9FFF) == <<0x00>>
  end

  test "VRAM Write" do
    assert GameKun.GPU.read(0x8001) == <<0x00>>
    GameKun.GPU.write(0x8001, <<0xFF>>)
    assert GameKun.GPU.read(0x8001) == <<0xFF>>

    assert GameKun.MMU.read(0x8001) == <<0xFF>>
    GameKun.MMU.write(0x8001, <<0x00>>)
    assert GameKun.MMU.read(0x8001) == <<0x00>>
  end
end
