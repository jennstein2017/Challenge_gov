use Mix.Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :challenge_gov, Web.Endpoint,
  http: [:inet4, port: System.get_env("PORT") || 4000],
  url: [host: System.get_env("HOST"), scheme: "https", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :challenge_gov, ChallengeGov.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "15")

# Do not print debug messages in production
config :logger, level: :info

# ## Using releases (distillery)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :challenge_gov, Web.Endpoint, server: true
#
# Note you can't rely on `System.get_env/1` when using releases.
# See the releases documentation accordingly.

config :challenge_gov, :recaptcha,
  module: ChallengeGov.Recaptcha.Implementation,
  secret_key: {:system, "RECAPTCHA_SECRET_KEY"},
  key: {:system, "RECAPTCHA_SITE_KEY"}

config :challenge_gov, ChallengeGov.Mailer,
  from: System.get_env("MAILER_FROM_ADDRESS"),
  adapter: Bamboo.SMTPAdapter,
  server: "smtp-relay.gmail.com",
  hostname: System.get_env("HOST"),
  port: 25,
  tls: :never,
  ssl: false,
  retries: 1

config :stein_storage,
  backend: :s3,
  bucket: {:system, "BUCKET_NAME"}

config :ex_aws,
  region: "us-gov-west-1",
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"}

config :challenge_gov, :oidc_config, %{
  idp_authorize_url: "https://idp.int.identitysandbox.gov/openid_connect/authorize",
  acr_value: "http://idmanagement.gov/ns/assurance/loa/1",
  redirect_uri: System.get_env("LOGIN_REDIRECT_URL"),
  client_id: System.get_env("LOGIN_CLIENT_ID"),
  private_key_path: System.get_env("LOGIN_PRIVATE_KEY_PATH"),
  private_key_password: System.get_env("LOGIN_PRIVATE_KEY_PASSWORD"),
  public_key_path: System.get_env("LOGIN_PUBLIC_KEY_PATH")
}

config :challenge_gov,
  session_timeout_in_minutes: System.get_env("SESSION_TIMEOUT_IN_MINUTES") || 15,
  account_deactivation_in_days: System.get_env("ACCOUNT_DEACTIVATION_IN_DAYS") || 90,
  account_decertify_in_days: System.get_env("ACCOUNT_DECERTIFY_IN_DAYS") || 365,
  account_deactivation_warning_one_in_days:
    System.get_env("ACCOUNT_DEACTIVATION_WARNING_ONE_IN_DAYS") || 10,
  account_deactivation_warning_two_in_days:
    System.get_env("ACCOUNT_DEACTIVATION_WARNING_TWO_IN_DAYS") || 5,
  log_retention_in_days: System.get_env("LOG_RETENTION_IN_DAYS") || 180

config :challenge_gov, ChallengeGov.Scheduler,
  jobs: [
    {"@daily", {ChallengeGov.Accounts, :check_all_last_actives, []}},
    {"@daily", {ChallengeGov.SecurityLogs, :check_expired_records, []}},
    {"* * * * *", {ChallengeGov.SecurityLogs, :check_for_timed_out_sessions, []}}
  ]

if File.exists?("config/prod.secret.exs") do
  import_config "prod.secret.exs"
end
