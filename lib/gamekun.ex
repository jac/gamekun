defmodule GameKun do
  def main(args) do
    args
    |> parse_args()
    |> valid()
    |> run()
    |> IO.puts()
  end

  defp parse_args(args), do: OptionParser.parse(args, switches: [])

  defp valid({_, [path], _}), do: {File.exists?(path), path, "File Not Found"}
  defp valid(_), do: {false, nil, "Usage: gamekun <ROM_PATH>"}

  defp run({true, path, _}) do
    GameKun.Application.start(:normal, path)
    Process.sleep(:infinity)
  end

  defp run({false, _, message}), do: message
end
