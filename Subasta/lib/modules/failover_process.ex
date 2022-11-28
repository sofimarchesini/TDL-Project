defmodule FailoverProcess do
  def start() do
    server = System.get_env "server"

    listen(server, true)
  end

  def listen(server, failover_mode) do
    receive do
    after 1000 ->
      IO.puts "Ping.."
      if(Node.ping(:"#{server}") == :pang) do
        IO.puts "Server down! Taking over"
        Application.stop(:phoenix)
        Application.stop(:iasc_tp_subastas)

        Application.start(:phoenix)
        Application.start(:iasc_tp_subastas)
        failover_mode = false
      end
    end

    if(failover_mode) do
      listen(server, failover_mode)
    end
  end
end
