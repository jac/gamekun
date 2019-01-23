defmodule GameKunCartTest do
  use ExUnit.Case
  doctest GameKun.Cart
  alias GameKun.Cart
  alias GameKun.MMU

  # Comment out this file to ignore cart tests

  setup do
    cart = start_supervised!({Cart, "./cpu_instrs.gb"}, [])
    %{cart: cart}
  end

  test "Cart Read Bank 0" do
    # Strings are binaries so the following two are equivalent
    assert Cart.read(0x0134, 10) == "CPU_INSTRS"

    assert Cart.read(0x0134, 10) ==
             <<0x43, 0x50, 0x55, 0x5F, 0x49, 0x4E, 0x53, 0x54, 0x52, 0x53>>

    assert Cart.read(0x0690, 16) == "Passed all tests"
    assert Cart.read(0x0101, 1) == <<0xC3>>
    # Test through MMU
    assert MMU.read(0x0134, 10) == "CPU_INSTRS"
  end

  test "Cart Read Bank 1" do
    assert Cart.read(0x4295, 6) == "Failed"
    assert Cart.read(0x7295, 6) == "Failed"
    # Test through MMU
    assert MMU.read(0x4295, 6) == "Failed"
  end

  # External RAM using MBC not yet supported
  # test "External Ram" do
  #   assert Cart.read(0xA000, 1) == 0xFF
  # end
end
