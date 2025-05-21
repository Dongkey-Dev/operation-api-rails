class CreateCustomerAdminRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :customer_admin_rooms do |t|
      t.bigint :adminRoomId
      t.integer :customerId
      t.boolean :isActive
      t.datetime :createdAt

      t.timestamps
    end
  end
end
