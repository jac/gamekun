# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :gamekun,
  hram: %{
    0xFF10 => <<0x80>>,
    0xFF11 => <<0xBF>>,
    0xFF12 => <<0xF3>>,
    0xFF14 => <<0xBF>>,
    0xFF16 => <<0x3F>>,
    0xFF19 => <<0xBF>>,
    0xFF1A => <<0x7F>>,
    0xFF1B => <<0xFF>>,
    0xFF1C => <<0x9F>>,
    0xFF1E => <<0xBF>>,
    0xFF20 => <<0xFF>>,
    0xFF23 => <<0xBF>>,
    0xFF24 => <<0x77>>,
    0xFF25 => <<0xF3>>,
    0xFF26 => <<0xF1>>,
    0xFF40 => <<0x91>>,
    0xFF47 => <<0xFC>>,
    0xFF48 => <<0xFF>>,
    0xFF49 => <<0xFF>>,
    # CGB Only, will this effect non cgb games?
    0xFF70 => <<0x01>>
  },
  gb_reg: %{
    0 => <<0x00>>,
    1 => <<0x13>>,
    2 => <<0x00>>,
    3 => <<0xD8>>,
    4 => <<0x01>>,
    5 => <<0x4D>>,
    6 => <<0xB0>>,
    7 => <<0x01>>,
    :sp => 0xFFFE,
    :pc => 0x0100,
    :ime => 0,
    :ime_cycle_accuracy => false,
    :cycles => 0
  },
  cgb_reg: %{
    0 => <<0x00>>,
    1 => <<0x13>>,
    2 => <<0x00>>,
    3 => <<0xD8>>,
    4 => <<0x01>>,
    5 => <<0x4D>>,
    6 => <<0xB0>>,
    7 => <<0x01>>,
    :sp => 0xFFFE,
    :pc => 0x0100,
    :ime => 0,
    :ime_cycle_accuracy => false,
    :cycles => 0
  }

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :gamekun, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:gamekun, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env()}.exs"
