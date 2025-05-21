class CreateApiV1ChatMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :api_v1_chat_messages do |t|
      t.bigint :_id
      t.integer :operationRoomId
      t.bigint :userId
      t.string :content
      t.datetime :createdAt

      t.timestamps
    end
  end
end
