class CreateRoomUserEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :room_user_events do |t|
      t.integer :operationRoomId
      t.integer :userId
      t.string :eventType
      t.datetime :eventAt

      t.timestamps
    end
  end
end
