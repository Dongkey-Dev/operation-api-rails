class CreateApiV1OperationRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :api_v1_operation_rooms do |t|
      t.bigint :chatRoomId
      t.string :openChatLink
      t.string :originTitle
      t.string :title
      t.bigint :accumulatedPaymentAmount
      t.string :platformType
      t.string :roomType
      t.integer :customerAdminRoomId
      t.integer :customerAdminUserId
      t.datetime :dueDate
      t.datetime :createdAt
      t.datetime :updatedAt

      t.timestamps
    end
  end
end
