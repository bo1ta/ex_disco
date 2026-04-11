Path.wildcard("test/support/**/*.exs")
|> Enum.each(&Code.require_file/1)

ExUnit.start()
