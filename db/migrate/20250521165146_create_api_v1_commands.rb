class CreateApiV1Commands < ActiveRecord::Migration[8.0]
  def change
    create_table :api_v1_commands do |t|
      t.string :keyword
      t.string :description
      t.integer :customerId
      t.integer :operationRoomId
      t.boolean :isActive
      t.datetime :createdAt
      t.datetime :updatedAt
      t.boolean :isDeleted
      t.datetime :deletedAt

      t.timestamps
    end
  end
end
