defmodule Udipi.Repo do
  use Ecto.Repo,
    otp_app: :udipi,
    adapter: Ecto.Adapters.Postgres
end
