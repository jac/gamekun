defmodule GameKun.Cart do
  use GenServer
  alias __MODULE__

  defstruct headers: %{cgb: nil, mbc: nil, rom_size: nil, ram_size: nil},
            rom: nil,
            ram: nil,
            rom_bank: 1,
            ram_bank: 0

  # API

  def start_link(rom_path) do
    GenServer.start_link(__MODULE__, {rom_path, %Cart{}}, name: CART)
  end

  def read(pos, len) do
    GenServer.call(CART, {:read, pos, len})
  end

  def write(pos, val) do
    GenServer.cast(CART, {:write, pos, val})
  end

  # Server

  def init({rom_path, init_state}) do
    rom = File.read!(rom_path)
    # TODO: Read Save (Saved RAM)

    cart = %Cart{
      init_state
      | headers: %{
          cgb: :binary.part(rom, {0x143, 1}),
          mbc: :binary.part(rom, {0x147, 1}),
          rom_size: :binary.part(rom, {0x148, 1}),
          ram_size: :binary.part(rom, {0x149, 1})
        },
        rom: rom,
        ram: 0x0000..0x1FFF |> Stream.zip(Stream.cycle([<<0>>])) |> Enum.into(%{})
    }

    {:ok, cart}
  end

  def handle_call({:read, pos, len}, _from, cart) do
    val =
      cond do
        pos in 0x0000..0x3FFF ->
          :binary.part(cart.rom, {pos, len})

        pos in 0x4000..0x7FFF ->
          pos = pos - 0x4000

          actual =
            cart.rom_bank
            |> Kernel.*(0x4000)
            |> Kernel.+(pos)

          :binary.part(cart.rom, {actual, len})

        pos in 0xA000..0xBFFF ->
          pos = pos - 0xA000

          cond do
            cart.headers.mbc in [<<0x00>>, <<0x05>>, <<0x06>>] ->
              cart.ram_bank[pos]

            cart.headers.mbc in [<<0x0F>>, <<0x11>>, <<0x12>>, <<0x13>>] ->
              raise("MBC3 Needed")

            cart.headers.mbc in [<<0x01>>, <<0x02>>, <<0x03>>] ->
              raise("MBC1 Needed")

            true ->
              raise("Unimplemented Cart RAM at #{pos} with MBC #{cart.headers.mbc}")
          end

        true ->
          raise("Unimplemented read at #{pos} with MBC #{cart.headers.mbc}")
      end

    {:reply, val, cart}
  end

  def handle_cast({:write, _pos, _val}, cart) do
    {:noreply, cart}
  end
end
