class CreateApiV1RoomUserEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :api_v1_room_user_events do |t|
      t.integer :operationRoomId
      t.integer :userId
      t.string :eventType
      t.datetime :eventAt

      t.timestamps
    end
  end
end
