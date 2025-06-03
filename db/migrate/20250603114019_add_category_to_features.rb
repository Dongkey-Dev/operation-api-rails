class AddCategoryToFeatures < ActiveRecord::Migration[8.0]
  def change
    add_column :features, :category, :string, null: false, default: 'general'
    add_index :features, :category
  end
end
