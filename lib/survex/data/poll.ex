defmodule Survex.Poll do
  use Survex.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias Survex.{Repo, Poll, PollOption, Vote}

  @fields [:id, :title, :created_at, :updated_at]

  @primary_key false
  schema "polls" do
    field :id, :string, primary_key: true, autogenerate: {__MODULE__, :generate_id, []}
    field :title, :string

    has_many :options, PollOption, references: :id
    has_many :votes, Vote, references: :id

    timestamps()
  end

  def changeset(%__MODULE__{} = poll, params \\ %{}) do
    poll
    |> cast(params, @fields)
    |> validate_required([:title])
    |> cast_assoc(:options, required: true)
  end

  def generate_id, do: Nanoid.generate()

  def get_results(poll_id) do
    from(v in Vote,
      where: v.poll_id == ^poll_id,
      select: {v.option_id, count(v.option_id)},
      group_by: v.option_id
    )
    |> Survex.Repo.all()
    |> Enum.reduce(%{}, fn {option_id, votes}, acc -> Map.put(acc, option_id, votes) end)
  end

  def get_by_id(id) do
    Repo.one(
      from p in Poll,
        where: p.id == ^id,
        join: o in assoc(p, :options),
        as: :options,
        preload: ^[options: dynamic([options: o], o)]
    )
  end
end
