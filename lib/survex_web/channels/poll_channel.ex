defmodule SurvexWeb.PollChannel do
  use Phoenix.Channel

  @impl true
  def join("poll:" <> _poll_id, _message, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_info(:new_vote, %{topic: "poll:" <> poll_id} = socket) do
    results = Survex.Poll.get_results(poll_id)

    broadcast(socket, "update_result", results)
    {:noreply, socket}
  end
end
