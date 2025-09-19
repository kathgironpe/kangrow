defmodule KanGrow.Repo do
  use Ecto.Repo,
    otp_app: :kan_grow,
    adapter: Ecto.Adapters.Postgres
end
