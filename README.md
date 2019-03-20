# __GameKun__
### GameKun is a Game Boy emulator written in elixir.

I wrote GameKun to better learn Elixir and challenge myself by creating an application with many moving parts and lots of state.

To build the executable clone the project and run the follow command in the root of the project directory.
```
mix escript.build
```

This will generate an executable file. To run the emulator simply use the following command where `<path_to_rom>` is a path to a `.gb` rom.
```
./gamekun <path_to_rom>
```

The test rom `cpu_instrs.gb` comes from [Blargg's Test Roms](http://gbdev.gg8.se/files/roms/blargg-gb-tests/)
