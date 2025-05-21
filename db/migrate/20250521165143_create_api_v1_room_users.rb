class CreateApiV1RoomUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :api_v1_room_users do |t|
      t.integer :operationRoomId
      t.bigint :userId
      t.string :nickname
      t.string :role
      t.datetime :joinedAt
      t.datetime :leftAt

      t.timestamps
    end
  end
end
