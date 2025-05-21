class CreateFeatures < ActiveRecord::Migration[8.0]
  def change
    create_table :features do |t|
      t.string :name
      t.string :description
      t.datetime :createdAt
      t.datetime :updatedAt

      t.timestamps
    end
  end
end
