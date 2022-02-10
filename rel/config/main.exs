import Config

config :prim, Prim.Application, :main

config :prim, PrimWeb.Endpoint, url: [host: "prim.tedween.de"]

config :libcluster,
  topologies: [
    prim: [
      config: [
        hosts: [
          :main@tokyo,
          :worker@rio
        ]
      ]
    ]
  ]

logs_path = "/var/log/prim"

config :logger, :info_log, path: "#{logs_path}/info.log"
config :logger, :error_log, path: "#{logs_path}/error.log"

config :logger,
  backends: [
    {LoggerFileBackend, :info_log},
    {LoggerFileBackend, :error_log}
  ]
