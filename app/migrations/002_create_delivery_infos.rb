# frozen_string_literal: true

Sequel.migration do
  transaction
  change do
    create_table(:delivery_infos) do
      primary_key :id
      String :name, text: true, null: false
      String :address, text: true, null: false
      String :phone, text: true, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
      foreign_key :user_id, :users, null: false, key: [:id]
    end
  end
end
