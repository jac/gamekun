# __GameKun__
### GameKun is a Game Boy emulator written in elixir.

**This is a POC project which I gave myself as a challenge while learning Elixir**

To build the executable clone the project and run the follow command in the root of the project directory.
```
mix escript.build
```

This will generate an executable file. To run the emulator simply use the following command where `<path_to_rom>` is a path to a `.gb` or ~~`.gbc`~~ rom.
```
./gamekun <path_to_rom>
```
**Currently only Game Boy games are supported but Game Boy Color support is planned**

The test rom `cpu_instrs.gb` comes from [Blargg's Test Roms](http://gbdev.gg8.se/files/roms/blargg-gb-tests/)
