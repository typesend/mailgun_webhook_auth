# MailgunWebhookAuth

This is a Plug module for validating Mailgun Webhook requests in Elixir applications.

A 403 Unauthorized Webhook Request response is returned for all invalid requests. All other requests pass through unmodified.

## Installation

Add `mailgun_webhook_auth` to the `deps` function in your project's `mix.exs` file:

```elixir
defp deps do
  [{:mailgun_webhook_auth, "~> 1.0"}]
end
```
	
Then run `mix do deps.get, deps.compile` inside your project's directory.

## Usage

Recommended usage is within a pipeline, but it may be used within your Phoenix controllers; anywhere a Plug can be used.

It expects your private mailgun API token String to be passed at initialization.

#### Example Phoenix.Router

```elixir

pipeline :webhooks do
  plug :accepts, ["json"]
	plug MailgunWebhookAuth,
				api_token: Application.get_env(:your_application, :mailgun_key)
end

scope "/webhooks", YourApplication do
  pipe_through :webhooks
	
	post "/received", WebhookController, :received
	post "/delivered", WebhookController, :delivered
	post "/dropped", WebhookController, :dropped
	post "/bounced", WebhookController, :bounced
	post "/complaints", WebhookController, :complaints
	post "/unsubscribes", WebhookController, :unsubscribes
	post "/clicks", WebhookController, :clicks
	post "/opens", WebhookController, :opens
end

```

#### Example Mix.Config

```elixir

config :your_application, mailgun_key: "key-BLAHBLAHBLAH"
	
```

## Mailgun Documentation

See the Mailgun [Routes documentation](https://documentation.mailgun.com/user_manual.html#receiving-messages-via-http-through-a-forward-action) for more information.

## License

MailgunWebhookAuth uses the same Apache 2 license as Plug and the Elixir programming language. See the [license file](https://raw.githubusercontent.com/typesend/mailgun_webhook_auth/master/LICENSE) for more information.
