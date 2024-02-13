defmodule SurvexWeb.PollController do
  use SurvexWeb, :controller
  alias Survex.{Repo, Poll, Vote}
  import Ecto.Changeset, only: [validate_required: 2, validate_length: 3]

  def show(conn, %{"id" => id}) do
    poll = Poll.get_by_id(id)

    if poll,
      do: render(conn, :show, poll: poll),
      else: send_resp(conn, :not_found, "")
  end

  def create(conn, params) do
    with {:ok, validated_params} <- validate_create_params(params),
         parsed_params <- parse_create_params(validated_params),
         changeset <- Poll.changeset(%Poll{}, parsed_params),
         {:ok, poll} <- Repo.insert(changeset) do
      api_hostname = get_req_header(conn, "host")

      poll_api_location = "https://#{api_hostname}/polls/#{poll.id}"

      conn
      |> put_status(:created)
      |> put_resp_header("Location", poll_api_location)
      |> json(%{id: poll.id})
    else
      {:error, changeset} ->
        errors = Ecto.Changeset.traverse_errors(changeset, &translate_errors/1)

        conn |> put_status(:bad_request) |> json(errors)

      _ ->
        send_resp(conn, :internal_server_error, "")
    end
  end

  # TODO: check if option_id belongs to the poll and only allow voting if this is true
  def vote(conn, %{"id" => poll_id} = params) do
    option_id = Map.get(params, "optionId")

    conn = get_or_create_session_id(conn)

    if option_id do
      insert_result =
        %{poll_id: poll_id, option_id: option_id, session_id: conn.cookies["session_id"]}
        |> Vote.changeset()
        |> Repo.insert()

      case insert_result do
        {:ok, _} ->
          Phoenix.PubSub.broadcast(Survex.PubSub, "poll:#{poll_id}", :new_vote)

          resp(conn, :created, "")

        {:error, changeset} ->
          errors_include_unique_index_error? =
            Enum.any?(changeset.errors, fn {_key, {_, keyword_list}} ->
              keyword_list
              |> Keyword.values()
              |> Enum.any?(&(&1 == "votes_poll_id_session_id_index"))
            end)

          errors =
            if errors_include_unique_index_error?,
              do: %{error: "user already voted on this poll"},
              else: Ecto.Changeset.traverse_errors(changeset, &translate_errors/1)

          conn |> put_status(:bad_request) |> json(errors)
      end
    else
      conn
      |> put_status(:bad_request)
      |> json(%{error: "optionId must be provided"})
    end
  end

  defp parse_create_params(params) do
    options =
      params
      |> Map.get(:options)
      |> Enum.map(&%{title: &1})

    %{title: Map.get(params, :title), options: options}
  end

  defp validate_create_params(params) do
    default = %{title: nil, options: nil}
    types = %{title: :string, options: {:array, :string}}

    fields = Map.keys(types)

    changeset =
      {default, types}
      |> Ecto.Changeset.cast(params, fields)
      |> validate_required(fields)
      |> validate_length(:options, min: 2)

    if changeset.valid?,
      do: {:ok, changeset |> Ecto.Changeset.apply_changes()},
      else: {:error, changeset}
  end

  @four_hundred_days_in_seconds 60 * 60 * 24 * 400

  defp get_or_create_session_id(conn) do
    conn = fetch_cookies(conn, encrypted: ~w(session_id))

    if conn.cookies["session_id"] do
      conn
    else
      session_id = Ecto.UUID.generate()

      put_resp_cookie(conn, "session_id", session_id,
        encrypt: true,
        max_age: @four_hundred_days_in_seconds,
        http_only: true,
        secure: true
      )
      |> fetch_cookies(encrypted: ~w(session_id))
    end
  end

  defp translate_errors({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end
