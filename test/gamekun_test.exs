defmodule GameKunTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest GameKun

  test "Usage Message" do
    assert capture_io(fn -> GameKun.main([]) end) == "Usage: gamekun <ROM_PATH>\n"
    assert capture_io(fn -> GameKun.main(["-h"]) end) == "Usage: gamekun <ROM_PATH>\n"
    assert capture_io(fn -> GameKun.main(["--help"]) end) == "Usage: gamekun <ROM_PATH>\n"
  end

  test "File Not Found" do
    assert capture_io(fn -> GameKun.main([""]) end) == "File Not Found\n"
    assert capture_io(fn -> GameKun.main(["~/unlikely_to_be_a_real_path.gb"]) end) == "File Not Found\n"
  end
end
