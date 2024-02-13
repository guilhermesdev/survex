defmodule Survex.PollOption do
  use Survex.Schema
  import Ecto.Changeset

  schema "poll_options" do
    field :title, :string

    belongs_to :poll, Survex.Poll, type: :string
  end

  def changeset(%__MODULE__{} = poll_option, params \\ %{}) do
    poll_option
    |> cast(params, [:title])
    |> validate_required([:title])
  end
end
