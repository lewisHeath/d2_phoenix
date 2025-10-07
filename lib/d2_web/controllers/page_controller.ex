defmodule D2Web.PageController do
  use D2Web, :controller
  require Logger

  def home(conn, _params) do
    render(conn, :home)
  end

  def oauth(conn, _params) do
    Logger.info("OAuth endpoint hit")
    # Log the params and connect info for debugging
    Logger.debug("Connection info: #{inspect(conn)}")
    # Get the query params
    query_params = conn.query_params
    Logger.debug("Query params: #{inspect(query_params)}")
    # Assign the query params to the conn for use in the template
    conn = assign(conn, :query_params, query_params)
    # Request access_token from bungie
    # https://www.bungie.net/platform/app/oauth/token/
    # Make http request to bungie
    # Use HTTPoison or similar library
    res = HTTPoison.post("https://www.bungie.net/platform/app/oauth/token/",
      {:form, [
        client_id: "50681",
        client_secret: System.get_env("BUNGIE_CLIENT_SECRET"),
        grant_type: "authorization_code",
        code: query_params["code"]
      ]},
      [{"Content-Type", "application/x-www-form-urlencoded"}]
    )
    Logger.debug("Bungie response: #{inspect(res)}")
    # Get the access_token, refresh_token, and membership_id, token_type and expires_in from the response
    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body = Jason.decode!(body)
        access_token = body["access_token"]
        refresh_token = body["refresh_token"]
        membership_id = body["membership_id"]
        token_type = body["token_type"]
        expires_in = body["expires_in"]
        Logger.info("Access token: #{access_token}")
        Logger.info("Refresh token: #{refresh_token}")
        Logger.info("Membership ID: #{membership_id}")
        Logger.info("Token type: #{token_type}")
        Logger.info("Expires in: #{expires_in}")
        # Start the access token server but don't register the name globally
        {:ok, _pid} = DynamicSupervisor.start_child(D2.DynamicSupervisor, {D2.AccessTokenServer, %{
          access_token: access_token,
          refresh_token: refresh_token,
          membership_id: membership_id,
          token_type: token_type,
          expires_in: expires_in
        }})

        # https://www.bungie.net/Platform/User/GetMembershipsForCurrentUser/
        # get the users profile picture path
        {:ok, %HTTPoison.Response{status_code: 200, body: profile_body}} = HTTPoison.get("https://www.bungie.net/Platform/User/GetMembershipsForCurrentUser/",
          [{"Authorization", "#{token_type} #{access_token}"}, {"X-API-Key", "752a37c3e62042de897346cf076d0904"}]
        )
        profile_body = Jason.decode!(profile_body)
        bungie_user = profile_body["Response"]["bungieNetUser"]
        conn = conn |> assign(:bungie_user, bungie_user)
        conn |> render(:oauth)

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("Failed to get tokens from Bungie. Status code: #{status_code}, Body: #{body}")
        conn
        |> put_flash(:error, "Failed to get tokens from Bungie.")
        |> render(:oauth)
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTP request to Bungie failed: #{inspect(reason)}")
        conn
        |> put_flash(:error, "HTTP request to Bungie failed.")
        |> render(:oauth)
    end
  end
end
