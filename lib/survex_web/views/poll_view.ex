defmodule SurvexWeb.PollView do
  use SurvexWeb, :view
  alias Survex.Poll

  def render("show.json", %{poll: %Poll{} = poll}) do
    options = poll |> Map.get(:options) |> Enum.map(&%{id: &1.id, title: &1.title})

    %{
      id: poll.id,
      title: poll.title,
      created_at: poll.created_at,
      updated_at: poll.updated_at,
      options: options
    }
  end
end
