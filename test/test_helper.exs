{:ok, _} = Application.ensure_all_started(:ex_machina)
{:ok, _} = AbsintheQuarry.Repo.start_link()

Ecto.Adapters.SQL.Sandbox.mode(AbsintheQuarry.Repo, :manual)

ExUnit.start()
