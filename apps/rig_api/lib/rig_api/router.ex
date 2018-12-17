defmodule RigApi.Router do
  use RigApi, :router 

  pipeline :api do
    plug(:put_format, :json)
  end

  scope "/v1", RigApi do
    pipe_through(:api)

    resources("/messages", MessageController, only: [:create])

    scope "/users" do
      get("/", ChannelsController, :list_channels)
      get("/:user/sessions", ChannelsController, :list_channel_sessions)
    end

    scope "/tokens" do
      delete("/:jti", ChannelsController, :disconnect_channel_session)
    end

    scope "/session-blacklist" do
      post("/", SessionBlacklistController, :blacklist_session)
      get("/:session_id", SessionBlacklistController, :check_status)
    end

    scope "/apis" do
      get("/", ApisController, :list_apis)
      post("/", ApisController, :add_api)
      get("/:id", ApisController, :get_api_detail)
      put("/:id", ApisController, :update_api)
      delete("/:id", ApisController, :deactivate_api)
    end
  end

  scope "/health", RigApi do
    pipe_through(:api)
    get("/", HealthController, :check_health)
  end

  scope "/swagger-ui" do
    forward("/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :rig_api,
      swagger_file: "rig_api_swagger.json"
    )
  end

  def swagger_info do
    %{rig: rig_version} = versions()

    %{
      info: %{
        version: rig_version,
        title: "RIG Control API",
        description: "This is the description for the RIG Control API exposed on Port 4010 by default or API_PORT within the config-file.
        It manages the Proxy APIs or user connections for RIGs proxy."
      }
    }
  end

  defp versions do
    {map, []} = Code.eval_file("version", "../..")
    map
  end
end