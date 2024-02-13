defmodule Survex.Repo.Migrations.CreatePollsOptionsAndVotes do
  use Ecto.Migration

  def change do
    create table(:poll_options) do
      add(:title, :string, null: false)
      add(:poll_id, references(:polls, type: :string), null: false)
    end

    create table(:votes) do
      add(:session_id, :string, null: false)
      add(:poll_id, references(:polls, type: :string), null: false)
      add(:option_id, references(:poll_options), null: false)

      timestamps(updated_at: false)
    end

    create(unique_index(:votes, [:poll_id, :session_id]))
  end
end
