defmodule Thumbifier.Util.Email do
  def create(subject, to, from, body) do
    %Mailman.Email {
      subject: subject,
      from: from,
      to: [to],
      html: body
    }
  end

  def deliver(email) do
    Mailman.deliver(email, config)
  end

  defp config do
    %Mailman.Context {
      config:   %Mailman.SmtpConfig{
        relay: Application.get_env(:thumbifier, Thumbifier.Util.Email) |> Keyword.get(:hostname),
        username: Application.get_env(:thumbifier, Thumbifier.Util.Email) |> Keyword.get(:username),
        password: Application.get_env(:thumbifier, Thumbifier.Util.Email) |> Keyword.get(:password),
        port: Application.get_env(:thumbifier, Thumbifier.Util.Email) |> Keyword.get(:port),
        ssl: false,
        tls: :always,
        auth: :always
      },
      composer: %Mailman.EexComposeConfig{}
    }
  end
end
