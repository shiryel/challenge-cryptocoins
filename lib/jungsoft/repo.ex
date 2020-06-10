defmodule Jungsoft.Repo do
  use Ecto.Repo,
    otp_app: :jungsoft,
    adapter: Ecto.Adapters.Postgres
end
