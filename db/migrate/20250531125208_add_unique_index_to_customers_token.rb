class AddUniqueIndexToCustomersToken < ActiveRecord::Migration[8.0]
  def change
    # Remove any existing non-unique index on token if it exists
    remove_index :customers, :token, if_exists: true

    # Add unique index to token
    add_index :customers, :token, unique: true
  end
end
