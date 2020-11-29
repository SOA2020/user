# frozen_string_literal: true

USER_ROUTE = proc do
  post "/login" do
    req = JSON.parse(request.body.read)
    user, token = User.login(req["email"], req["password"])
    yajl :login, locals: { token: token, user: user }
  end

  post "/register" do
    req = JSON.parse(request.body.read)
    user = User.create(
      email: req["email"],
      password: CryptoService.generate(req["password"]),
      nickname: req["nickname"],
    )
    yajl :empty
  rescue Sequel::UniqueConstraintViolation => _e
    raise UnauthorizedError.new("User Existed")
  end

  # View profile
  get "/:id" do |id|
    user = User.auth!(request)
    entity = User.where(id: id)&.first
    raise NotFoundError.new("User: #{id}", "User Not Existed") if user.nil?
    user.own!(entity)
    yajl :profile, locals: { user: user }
  end

  # Edit profile
  put "/:id" do |id|
    user = User.auth!(request)
    entity = User.where(id: id)&.first
    raise NotFoundError.new("User: #{id}", "User Not Existed") if user.nil?
    user.own!(entity)

    req = JSON.parse(request.body.read)
    entity.password = CryptoService.generate(req["password"]) unless req["password"].nil?
    entity.nickname = req["nickname"] unless req["nickname"].nil?
    entity.email = req["email"] unless req["email"].nil?
    entity.save

    yajl :profile, locals: { user: entity }
  end
end
