defmodule MailgunWebhookAuth.Mixfile do
  use Mix.Project

  def project do
		[ app: :mailgun_webhook_auth,
			version: "1.0.0",
			elixir: "~> 1.2",
			build_embedded: Mix.env == :prod,
			start_permanent: Mix.env == :prod,
			name: "Mailgun Webhook Auth",
			source_url: "https://github.com/typesend/mailgun_webhook_auth",
			homepage_url: "https://github.com/typesend/mailgun_webhook_auth",
			docs: [readme: "README.md", main: "README"],
			package: package,
			description: description,
			deps: deps
		]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [{:cowboy, "~> 1.0"},
     {:plug, "~> 0.13 or ~> 1.0"},
     {:ex_doc, "~> 0.7", only: :dev}]
  end

  defp package do
    [
			files: ["lib", "mix.exs", "README*", "LICENSE*"],
			licenses: ["Apache 2.0"],
      maintainers: ["Ben Damman"],
      links: %{"Github" => "https://github.com/typesend/mailgun_webhook_auth",
							 "Docs" => "https://github.com/typesend/mailgun_webhook_auth/blob/master/README.md"}
		]
  end
	
	defp description do
		"""
		A Plug for validating Mailgun Webhook requests in Elixir applications.
		"""
	end
end
