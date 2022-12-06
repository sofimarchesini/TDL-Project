defmodule Subasta do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    IO.puts("Callback application start")
    type = System.get_env("type")
    server = System.get_env("server")
    IO.puts(type)

    if type == "client" do
      IO.puts("Connecting client to #{server} ...")
      Node.connect(:"#{server}")

      {:ok, self}
    else
      if type == "failover" do
        if(Node.ping(:"#{server}") == :pang) do
          start_server
        end

        {:ok, self}
      else
        start_server
      end
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Subasta.Endpoint.config_change(changed, removed)
    :ok
  end

  def start_server do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(Subasta.Endpoint, []),
      # Start the Ecto repository
      worker(Subasta.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(IascTpSubastas.Worker, [arg1, arg2, arg3]),

      worker(SubasteroServer, [[name: {:global, GlobalSubastero}]], restart: :transient),
      worker(SubastasHome, [[name: {:global, GlobalSubastasHome}]], restart: :transient),
      worker(CompradoresHome, [[name: {:global, GlobalCompradoresHome}]], restart: :transient)
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: IascTpSubastas.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
