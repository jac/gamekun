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
    GenServer.start_link(__MODULE__, rom_path, name: CART)
  end

  def read(pos, len) do
    GenServer.call(CART, {:read, pos, len})
  end

  def write(pos, val) do
    GenServer.call(CART, {:write, pos, val})
  end

  # Server

  def init(rom_path) do
    rom = File.read!(rom_path)
    # TODO: Read Save (Saved RAM)
    default = %Cart{}

    cart = %Cart{
      default
      | headers: %{
          cgb: :binary.part(rom, {0x143, 1}),
          mbc: :binary.part(rom, {0x147, 1}),
          rom_size: :binary.part(rom, {0x148, 1}),
          ram_size: :binary.part(rom, {0x149, 1})
        },
        rom: rom,
        ram: 0x0000..0x1FFF |> Stream.zip(Stream.cycle([0x00])) |> Enum.into(%{})
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
            cart.headers.mbc in [<<0x0F>>, <<0x11>>, <<0x13>>, <<0x13>>] ->
              raise("MBC3 Needed")

            cart.headers.mbc in [<<0x05>>, <<0x06>>] ->
              :binary.part(cart.ram_bank, {pos, len})

            cart.headers.mbc in [<<0x01>>, <<0x02>>, <<0x03>>] ->
              raise("MBC1 needed")

            cart.headers.mbc == <<0x00>> ->
              :binary.part(cart.ram_bank, {pos, len})

            true ->
              raise("Unimplemented Cart RAM at #{pos} with MBC #{cart.headers.mbc}")
          end

        true ->
          raise("Unimplemented read at #{pos} of len #{len} with MBC #{cart.headers.mbc}")
      end

    {:reply, val, cart}
  end

  def handle_call({:write, _pos, _val}, _from, _cart) do
    raise("Unimplemented Cart Write")
    {:reply, :ok}
  end
end
