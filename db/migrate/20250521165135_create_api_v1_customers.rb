class CreateApiV1Customers < ActiveRecord::Migration[8.0]
  def change
    create_table :api_v1_customers do |t|
      t.bigint :userId
      t.string :name
      t.string :email
      t.string :phoneNumber
      t.string :password
      t.datetime :lastLoginAt
      t.datetime :createdAt
      t.datetime :updatedAt

      t.timestamps
    end
  end
end
