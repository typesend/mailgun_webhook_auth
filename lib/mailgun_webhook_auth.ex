defmodule MailgunWebhookAuth do
	@moduledoc """
	A Plug for validating Mailgun Webhook requests in Elixir applications.
	
	It expects your private mailgun API token String to be passed at initialization.
		
	A 403 Unauthorized Webhook Request response is returned for all invalid requests.
	
	Recommended usage is within a pipeline, but it may be used within your
	Phoenix controllers; anywhere a Plug can be used.
	
	## Example Phoenix.Router
	
		  pipeline :webhooks do
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
			
	## Example Mix.Config
			
			config :your_application,
				mailgun_key: "key-BLAHBLAHBLAH"
				
	## Mailgun Documentation
	
	See the Mailgun [Routes documentation](https://documentation.mailgun.com/user_manual.html#receiving-messages-via-http-through-a-forward-action) for more information.
	
	"""
	
	import Plug.Conn
	
  def init(opts) do
    case Keyword.fetch(opts, :api_token) do
      {:ok, api_token} -> api_token
      :error -> raise_undefined_option_error(opts)
    end
  end
	
	def call(conn, api_token), do: validate_request(conn, api_token)
	 
	def validate_request(conn, api_token) do
		%{"token" => token,
			"signature" => signature,
			"timestamp" => timestamp} = conn.body_params
		if valid?(api_token, token, timestamp, signature) do
			conn
		else
			conn |> unauthorized
		end
	rescue
		MatchError -> unauthorized(conn)
		_ -> unauthorized(conn)
	end
	
	defp unauthorized(conn) do
		conn
		|> send_resp(403, "Unauthorized Webhook Request")
		|> halt
	end
	
	def valid?(api_token, token, timestamp, signature) do
		[timestamp, token]
		|> Enum.join
		|> hmac(api_token)
		|> matches?(signature)
	end
		
	def hmac(data, key) do
		:crypto.hmac(:sha256, key, data)
		|> Base.encode16
		|> String.downcase
	end
	
	defp matches?(computed_sig, sig) do
		computed_sig == String.downcase(sig)
	end
	
  defp raise_undefined_option_error(_) do
		raise ":api_key option is not defined"
  end
	
end
