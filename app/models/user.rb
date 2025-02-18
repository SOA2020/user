# frozen_string_literal: true

class User < Sequel::Model
  plugin :timestamps, update_on_create: true

  def self.login(email, password)
    user = User.where(email: email)&.first
    raise UnauthorizedError, 'User Not Exsited' if user.nil?
    raise UnauthorizedError, 'Password Incorrect' unless CryptoService.verify(password, user.password)

    token = SecureRandom.uuid62
    Token.create(token: token, user_id: user.id)
    [user, token]
  end

  def admin?
    is_admin
  end

  def admin!
    raise UnauthorizedError, 'Admin Only' unless admin?
  end

  def own?(user)
    admin? || self == user
  end

  def own!(user)
    raise UnauthorizedError, 'User NOT Allowed' unless own?(user)
  end

  def self.auth(request)
    user = Token.find(token: request.env['HTTP_TOKEN'])&.first
    user.nil? ? nil : User.where(id: user.user_id)&.first
  end

  def self.auth!(request)
    user = auth(request)
    user.nil? ? raise(UnauthorizedError, 'Token NOT Verified') : user
  end
end
