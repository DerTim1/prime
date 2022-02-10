# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :libcluster,
  debug: true,
  topologies: [
    prim: [
      # The selected clustering strategy. Required.
      strategy: Cluster.Strategy.Epmd,
      # Configuration for the provided strategy. Optional.
      config: [hosts: [:main@lukes, :worker1@lukes]],
      # The function to use for connecting nodes. The node
      # name will be appended to the argument list. Optional
      connect: {:net_kernel, :connect_node, []},
      # The function to use for disconnecting nodes. The node
      # name will be appended to the argument list. Optional
      disconnect: {:erlang, :disconnect_node, []},
      # The function to use for listing nodes.
      # This function must return a list of node names. Optional
      list_nodes: {:erlang, :nodes, [:connected]}
    ]
    # prim: [
    #   strategy: Elixir.Cluster.Strategy.Gossip,
    #   config: [
    #     port: 45899,
    #     if_addr: "0.0.0.0",
    #     # multicast_if: "127.0.0.1",
    #     multicast_addr: "239.252.1.32",
    #     broadcast_only: true,
    #     secret: "cohm8joh9eigaeFee9ieReigh3shohsh"
    #   ]
    # ]
  ]

# Configures the endpoint
config :prim, PrimWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: PrimWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Prim.PubSub,
  live_view: [signing_salt: "Uk775DVI"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :prim, Prim.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  level: :debug,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger, level: :debug

config :logger,
  backends: [
    :console,
    {LoggerFileBackend, :debug_log},
    {LoggerFileBackend, :info_log},
    {LoggerFileBackend, :error_log}
  ]

logs_path = System.get_env("LOGS_PATH")

config :logger, :console,
  level: :debug,
  colors: [enabled: true],
  metadata: [:module],
  format: "$date $time [$level] [$metadata] $message\n"

config :logger, :debug_log,
  path: "#{logs_path}/debug.log",
  level: :debug,
  metadata: [:application, :module, :context],
  format: "$date $time [$level] [$metadata] $message\n"

config :logger, :info_log,
  path: "#{logs_path}/info.log",
  level: :info,
  metadata: [:application, :module, :context],
  format: "$date $time [$level] [$metadata] $message\n"

config :logger, :error_log,
  path: "#{logs_path}/error.log",
  level: :error,
  metadata: [:application, :module, :function, :file, :line, :context],
  format: "$date $time [$level] [$metadata] $message\n"

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
