defmodule Thumbifier.Messenger do
  def account_created(from, to, key) do
    Thumbifier.Util.Email.create("Welcome to Thumbify.me", to, from, welcome_content(to, key))
    |> Thumbifier.Util.Email.deliver
  end

  defp welcome_content(email, key) do
    """
      <html>
      <head>
      </head>
      <body>
        <h1>Thanks for joining Thumbify.me</h1>
        <h3>Here are your access credentials</h3>
        <ul>
          <li><strong>Email:</strong> #{email}</li>
          <li><strong>API Key:</strong> #{key}</li>
        </ul>
      </body>
      </html>
    """
  end
end
