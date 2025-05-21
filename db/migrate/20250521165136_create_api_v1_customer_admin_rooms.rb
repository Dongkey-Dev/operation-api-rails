class CreateApiV1CustomerAdminRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :api_v1_customer_admin_rooms do |t|
      t.bigint :adminRoomId
      t.integer :customerId
      t.boolean :isActive
      t.datetime :createdAt

      t.timestamps
    end
  end
end
