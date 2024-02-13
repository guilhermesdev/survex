defmodule SurvexWeb.LiveView.CreatePollPage do
  @moduledoc """
  The poll creation page live view
  """

  use Phoenix.LiveView

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
