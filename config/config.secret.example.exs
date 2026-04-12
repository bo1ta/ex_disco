import Config

config :ex_disco, ExDisco,
  # Custom User-Agent sent with every request.
  # Discogs asks that you identify your app; default is "ex_disco/0.1.0".
  user_agent: "my_app/1.0.0 (+https://github.com/me/my_app)",

  # --- Authentication (pick one) ---

  # Option A: Personal token.
  # Simplest option — only acts as you. Good for personal scripts and CLIs.
  # Generate one at https://www.discogs.com/settings/developers
  user_token: "your_personal_token_here"

# Option B: OAuth 1.0a app credentials.
# Required when acting on behalf of other users.
# Register your app at https://www.discogs.com/settings/developers to get these.
# consumer_key: "your_consumer_key_here",
# consumer_secret: "your_consumer_secret_here"
