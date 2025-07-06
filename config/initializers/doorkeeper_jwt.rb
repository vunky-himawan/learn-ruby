Doorkeeper::JWT.configure do
  token_payload do |opts|
    user = User.find(opts[:resource_owner_id])

    {
      iss: "MyApp",
      iat: Time.current.to_i,
      exp: (Time.current + (ENV["JWT_EXPIRE_SECONDS"] || 7200).to_i.seconds).to_i,
      sub: user.id,
      email: user.email
    }
  end

  signing_method :hs256
  secret_key ENV.fetch("JWT_SECRET")
end
