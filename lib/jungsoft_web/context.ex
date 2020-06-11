defmodule JungsoftWeb.Context do
  @moduledoc """
  Plug to make the Absinthe schema context

  Populates the context with the `%{current_user: %User{...}}` info
  """

  alias Jungsoft.Exchages
  import Plug.Conn
  require Logger

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, data} <- JungsoftWeb.Authentication.verify(token),
         %{} = user <- get_user(data) do
      Logger.debug("User inserted in context build: #{user.id}")
      %{current_user: user}
    else
      _ ->
        Logger.debug("User rejected in context build")
        %{}
    end
  end

  defp get_user(%{id: id}) do
    Exchages.get_user(id)
  end
end
