class AddIsAdminToCustomers < ActiveRecord::Migration[8.0]
  def change
    add_column :customers, :is_admin, :boolean, default: false, null: false
  end
end
