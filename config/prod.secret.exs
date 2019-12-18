use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :twitsim, TwitsimWeb.Endpoint,
  secret_key_base: "hB+09wBIb2DSUl5PIVtP68F15DoKEsNO2M9WYO3su1f/+ih069zpWmAJBDeC5ALg"

# Configure your database
config :twitsim, Twitsim.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "twitsim_prod",
  pool_size: 15
