use Mix.Config

# set to :debug to view SQL queries in logs
config :logger, level: :warn

config :absinthe_quarry,
  ecto_repos: [AbsintheQuarry.Repo]

config :absinthe_quarry, AbsintheQuarry.Repo,
  adapter: Ecto.Adapters.SQLite3,
  database: "#{Mix.env()}.db",
  priv: "test/support",
  pool: Ecto.Adapters.SQL.Sandbox
