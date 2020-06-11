defmodule JungsoftWeb.Router do
  @dialyzer {:nowarn_function, __checks__: 0}
  use JungsoftWeb, :router

  if Mix.env() == :dev do
    forward "/api", Absinthe.Plug.GraphiQL,
      schema: JungsoftWeb.Schema,
      socket: JungsoftWeb.UserSocket,
      json_codec: Phoenix.json_library(),
      interface: :playground
  else
    forward "/api", Absinthe.Plug,
      schema: JungsoftWeb.Schema,
      socket: JungsoftWeb.UserSocket,
      json_codec: Phoenix.json_library()
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: JungsoftWeb.Telemetry
    end
  end
end
