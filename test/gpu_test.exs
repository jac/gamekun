defmodule GameKunGPUTest do
  use ExUnit.Case
  doctest GameKun.GPU
  alias GameKun.GPU
  alias GameKun.MMU

  setup do
    gpu = start_supervised!({GPU, nil})
    ram = start_supervised!({GameKun.RAM, nil})
    %{gpu: gpu, ram: ram}
  end

  test "VRAM Read" do
    assert GPU.read(0x8000) == <<0x00>>
    assert GPU.read(0x9FFF) == <<0x00>>

    assert MMU.read(0x9FFF) == <<0x00>>
  end

  test "VRAM Write" do
    assert GPU.read(0x8001) == <<0x00>>
    GPU.write(0x8001, <<0xFF>>)
    assert GPU.read(0x8001) == <<0xFF>>

    assert MMU.read(0x8001) == <<0xFF>>
    MMU.write(0x8001, <<0x00>>)
    assert MMU.read(0x8001) == <<0x00>>
  end
end
