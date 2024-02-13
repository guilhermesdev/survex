defmodule Survex.Vote do
  use Survex.Schema
  import Ecto.Changeset

  @fields [:session_id, :poll_id, :option_id]

  schema "votes" do
    field :session_id, :string

    belongs_to :poll, Survex.Poll, type: :string
    belongs_to :option, Survex.PollOption, type: :binary_id

    timestamps(updated_at: false)
  end

  def changeset(params) do
    %__MODULE__{}
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint([:poll_id, :session_id])
  end
end
