defmodule GameKun.GPU do
  use GenServer
  use Bitwise
  alias __MODULE__, as: GPU_S
  alias GameKun.MMU, as: MMU
  defstruct vram: %{}, mode: 1, clock: 0, line: 0, line_buffer: []

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: GPU)
  end

  def read(pos) do
    GenServer.call(GPU, {:read, pos})
  end

  def step(amt) do
    GenServer.call(GPU, {:step, amt})
  end

  def write(pos, value) do
    GenServer.cast(GPU, {:write, pos, value})
  end

  # Server
  def init(_args) do
    vram =
      0x8000..0xBFFF
      |> Stream.concat(0xFE00..0xFE90)
      |> Stream.zip(Stream.cycle([<<0x00>>]))
      |> Enum.into(%{})

    state = %GPU_S{vram: vram}
    clear_screen()
    {:ok, state}
  end

  def handle_call({:read, pos}, _from, state) do
    actual = actual_position(pos)
    value = state.vram[actual]
    {:reply, value, state}
  end

  def handle_call({:step, amt}, _from, state) do
    state = gpu_step(%{state | clock: state.clock + amt})
    update_memory_registers(state)
    {:reply, nil, state}
  end

  def handle_cast({:write, pos, value}, state) do
    actual = actual_position(pos)
    state = put_in(state.vram[actual], value)
    {:noreply, state}
  end

  defp actual_position(pos) do
    GameKun.MMU.read(0xFF4F)
    |> :binary.decode_unsigned()
    |> Bitwise.band(1)
    |> Kernel.*(0x2000)
    |> Kernel.+(pos)
  end

  def gpu_step(%{mode: 0, clock: clock} = state) when clock >= 204 do
    clock = 0
    line = state.line + 1
    state = %{state | clock: clock, line: line}

    if line == 144 do
      move_cursor_to_start()
      send_interrupt(1)
      %{state | mode: 1}
    else
      %{state | mode: 2}
    end
  end

  def gpu_step(%{mode: 1, clock: clock} = state) when clock >= 456 do
    clock = 0
    line = state.line + 1
    state = %{state | clock: clock, line: line}
    if line > 153, do: %{state | mode: 2, line: 0}, else: state
  end

  def gpu_step(%{mode: 2, clock: clock} = state) when clock >= 80 do
    %{state | mode: 3, clock: 0}
  end

  def gpu_step(%{mode: 3, clock: clock} = state) when clock >= 172 do
    %{render_scanline(state) | mode: 0, clock: 0}
  end

  def gpu_step(state) do
    state
  end

  def update_memory_registers(state) do
    MMU.write(0xFF44, <<state.line>>)

    MMU.read(0xFF41)
    |> interrupt()
  end

  # Stat Interrupt
  def interrupt(<<_::1, 1::1, _::3, 1::1, _::2>>), do: send_interrupt(2)
  def interrupt(<<_::4, 1::1, _::1, 0::2>>), do: send_interrupt(2)
  def interrupt(<<_::2, 1::1, _::3, 2::2>>), do: send_interrupt(2)

  def interrupt(<<_::2, oam::1, vblank::1, _::2, 1::2>>) when oam == 1 or vblank == 1,
    do: send_interrupt(2)

  def interrupt(_), do: nil

  def send_interrupt(or_val) do
    <<interrupts>> = MMU.read(0xFFFF)
    MMU.write(0xFFFF, <<interrupts ||| or_val>>)
  end

  def clear_screen() do
    IO.write("\u001b[2J")
    move_cursor_to_start()
  end

  def move_cursor_to_start() do
    IO.write("\u001b[0;0H")
  end

  def render_scanline(state) do
    <<lcdc>> = MMU.read(0xFF40)
    <<scy>> = MMU.read(0xFF42)
    <<scx>> = MMU.read(0xFF43)
    palette = MMU.read(0xFF47)

    # Address of 32x32 Tile Map start - 0x9C00 or 0x9800
    map_addr = if (lcdc &&& 0x08) == 0x08, do: 0x9C00, else: 0x9800
    # Y - Address in map for which current line starts (Each line is 0x20 bytes)
    map_y = map_addr + ((state.line + scy &&& 0xFF) >>> 3) * 0x20
    # X - Offset of current line (Y) in map
    map_x = scx >>> 3

    # Start of tile section (Tile 0 of 0..255, Tile -128 of -128..127)
    tile_section = if (lcdc &&& 0x10) == 0x10, do: 0x8000, else: 0x8800
    pixel(0, map_y, map_x, state, scy, scx, tile_section, palette)
  end

  def pixel(
        render_x,
        map_y,
        map_x,
        state,
        scy,
        scx,
        tile_section,
        <<c3::2, c2::2, c1::2, c0::2>> = palette
      )
      when render_x < 160 do
    # Get tile number from map
    <<tile_num>> = state.vram[map_y + map_x]
    # Adjustment amount to get actual value if signed second map
    adjustment = if tile_section == 0x8000, do: tile_num, else: rem(tile_num + 128, 256)
    tile_addr = tile_section + adjustment * 0x10
    # Line of pixels in tile
    pixel_y = state.line + scy &&& 7
    pixel_line = tile_addr + pixel_y * 2
    # Pixel offset in line of tile
    pixel_x = scx &&& 7
    # Number of bits below relevant bit
    below = 7 - pixel_x
    # Pattern match on relevant bits
    <<_::size(pixel_x), lsb::1, _::size(below)>> = state.vram[pixel_line]
    <<_::size(pixel_x), msb::1, _::size(below)>> = state.vram[pixel_line + 1]

    # Upper/Lower of terminal character
    pixel_ul = if rem(state.line, 2) == 0, do: {0, "▀"}, else: {10, ""}

    pixel =
      (msb <<< 1 ||| lsb)
      |> case do
        0 -> palette(c0, pixel_ul)
        1 -> palette(c1, pixel_ul)
        2 -> palette(c2, pixel_ul)
        3 -> palette(c3, pixel_ul)
      end

    # Add pixel to buffer - result is [bottom0, top0,...,bottom159, top159]
    state = %{state | line_buffer: List.insert_at(state.line_buffer, render_x * 2, pixel)}
    # Increment X
    {scx, map_x} = increment_x(pixel_x, map_x)
    # Render next pixel
    pixel(render_x + 1, map_y, map_x, state, scy, scx, tile_section, palette)
  end

  def pixel(_, _, _, %{line_buffer: line} = state, _, _, _, _) when length(line) == 320,
    do: draw_line(state)

  def pixel(_, _, _, state, _, _, _, _), do: state

  # Return ansi for coloured pixel
  def palette(0, {offset, char}), do: "\e[#{97 + offset}m#{char}"
  def palette(1, {offset, char}), do: "\e[#{37 + offset}m#{char}"
  def palette(2, {offset, char}), do: "\e[#{90 + offset}m#{char}"
  def palette(3, {offset, char}), do: "\e[#{30 + offset}m#{char}"

  # At the end of a tile move to the next one
  def increment_x(7, map_x), do: {0, map_x + 1 &&& 31}
  # Move to the next pixel in a tile
  def increment_x(x, map_x), do: {x + 1, map_x}

  def draw_line(state) do
    (Enum.reduce(state.line_buffer, "", &(&2 <> &1)) <> "\e[0m #{state.line}\n")
    |> IO.write()

    %{state | line_buffer: []}
  end
end
