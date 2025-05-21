class CreateApiV1RoomUserNicknameHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :api_v1_room_user_nickname_histories do |t|
      t.integer :chatRoomId
      t.integer :userId
      t.string :previousNickname
      t.string :newNickname
      t.datetime :createdAt
      t.boolean :isDeleted
      t.datetime :deletedAt

      t.timestamps
    end
  end
end
