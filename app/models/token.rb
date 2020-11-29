# frozen_string_literal: true

class Token < Ohm::Model
  attribute :token
  attribute :user_id

  index :token

  def user
    User.find(user_id)
  end
end
