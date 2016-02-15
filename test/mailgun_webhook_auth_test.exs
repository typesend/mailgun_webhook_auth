defmodule MailgunWebhookAuthTest do
  use ExUnit.Case, async: true
	use Plug.Test
  doctest MailgunWebhookAuth
	
	defmodule PrivatePlug do
		import Plug.Conn
		use Plug.Router
		
	  if Mix.env == :test do
	  	use Plug.Debugger
	  end
		
		plug MailgunWebhookAuth, api_token: "testing"
		plug :match
		plug :dispatch
		
		get "/" do
      conn
      |> assign(:called, true)
      |> put_resp_content_type("text/plain")
      |> send_resp(200, "Hello Tester")
    end
	end
	
	defp call(conn) do
    PrivatePlug.call(conn, [])
  end
	
	defp valid_body_params, do: valid_body_params("testing")
	defp valid_body_params(token) do
		timestamp = :os.system_time(:seconds)
		data = Enum.join([timestamp, token])
		signature = MailgunWebhookAuth.hmac(data, token)
		%{"token" => token, "signature" => signature, "timestamp" => timestamp}
	end
	
	defp invalid_body_params, do: invalid_body_params("testing")
	defp invalid_body_params(token) do
		%{"token" => token, "signature" => "XXXXXXXXXXXXXX", "timestamp" => :os.system_time(:seconds)}
	end

  test "valid webhook requests are passed through" do
    conn = %{ conn(:get, "/") | body_params: valid_body_params } |> call
    assert conn.status == 200
    assert conn.resp_body == "Hello Tester"
    assert conn.assigns[:called]
  end
	
  test "invalid webhook request fields are rejected" do
    conn = %{ conn(:get, "/") | body_params: invalid_body_params } |> call
		refute conn.assigns[:called]
  end
	
  test "invalid requests are rejected" do
		# body_params fields are completely missing
    conn = conn(:get, "/") |> call
		refute conn.assigns[:called]
  end
	
end
