class CreateApiV1RoomFeatures < ActiveRecord::Migration[8.0]
  def change
    create_table :api_v1_room_features do |t|
      t.integer :operationRoomId
      t.integer :featureId
      t.boolean :isActive
      t.datetime :createdAt
      t.datetime :updatedAt

      t.timestamps
    end
  end
end
