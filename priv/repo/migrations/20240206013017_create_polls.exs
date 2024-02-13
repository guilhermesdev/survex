defmodule Survex.Repo.Migrations.CreatePolls do
  use Ecto.Migration

  def change do
    create table(:polls, primary_key: false) do
      add(:id, :string, primary_key: true)
      add(:title, :string, null: false)

      timestamps()
    end
  end
end
