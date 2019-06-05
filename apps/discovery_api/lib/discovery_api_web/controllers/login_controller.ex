defmodule DiscoveryApiWeb.LoginController do
  require Logger
  use DiscoveryApiWeb, :controller
  alias DiscoveryApi.Auth.Guardian

  def new(conn, _) do
    {user, password} = extract_auth(conn)

    with :ok <- PaddleWrapper.authenticate(user, password) do
      {:ok, token, _claims} = Guardian.encode_and_sign(user)

      conn
      |> Plug.Conn.put_resp_header("token", token)
      |> Guardian.Plug.sign_in(user)
      |> Guardian.Plug.remember_me(user)
      |> text("#{user} logged in.")
    else
      {:error, :invalidCredentials} -> render_error(conn, 401, "Not Authorized")
    end
  end

  defp extract_auth(conn) do
    conn
    |> Plug.Conn.get_req_header("authorization")
    |> List.last()
    |> String.split(" ")
    |> List.last()
    |> Base.decode64!()
    |> String.split(":")
    |> List.to_tuple()
  end

  defp extract_token(conn) do
    conn
    |> Plug.Conn.get_req_header("authorization")
    |> List.last()
    |> String.split(" ")
    |> List.last()
  end

  def logout(conn, _) do
    jwt = extract_token(conn)

    with {:ok, _claims} <- Guardian.revoke(jwt) do
      conn
      |> Guardian.Plug.sign_out(clear_remember_me: true)
      |> text("Logged out.")
    else
      {:error, _error} ->
        render_error(conn, 404, "Not Found")
    end
  end
end
