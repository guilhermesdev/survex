defmodule Survex.Repo do
  use Ecto.Repo,
    otp_app: :survex,
    adapter: Ecto.Adapters.SQLite3
end
