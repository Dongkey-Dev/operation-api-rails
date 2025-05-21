class CreateApiV1Plans < ActiveRecord::Migration[8.0]
  def change
    create_table :api_v1_plans do |t|
      t.string :name
      t.string :description
      t.integer :price
      t.json :features
      t.datetime :createdAt
      t.datetime :updatedAt

      t.timestamps
    end
  end
end
