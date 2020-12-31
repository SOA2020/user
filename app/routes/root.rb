# frozen_string_literal: true

ROOT_ROUTE = proc do
  get '' do
    { status: 'running' }.to_json
  end

  post "login" do
    req = JSON.parse(request.body.read)
    user, token = User.login(req["email"], req["password"])
    yajl :login, locals: { token: token, user: user }
  end

  post "register" do
    req = JSON.parse(request.body.read)
    user = User.create(
      email: req["email"],
      password: CryptoService.generate(req["password"]),
      nickname: req["nickname"],
      avatar: "default",
      is_admin: false,
    )
    yajl :profile, locals: { user: user }
  rescue Sequel::UniqueConstraintViolation => _e
    raise UnauthorizedError.new("User Existed")
  end
end
