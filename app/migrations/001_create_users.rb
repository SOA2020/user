# frozen_string_literal: true

Sequel.migration do
  transaction
  change do
    create_table(:users) do
      primary_key :id
      String :email, size: 255, null: false, unique: true
      String :password, size: 255, null: false
      String :nickname, null: false
      TrueClass :is_admin, null: false, default: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
