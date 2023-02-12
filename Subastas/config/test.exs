use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :subasta, Subasta.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :subasta, Subasta.Repo,
  adapter: Mongo.Ecto,
  database: "subasta_test",
  pool_size: 1
