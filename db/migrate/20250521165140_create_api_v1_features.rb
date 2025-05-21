class CreateApiV1Features < ActiveRecord::Migration[8.0]
  def change
    create_table :api_v1_features do |t|
      t.string :name
      t.string :description
      t.datetime :createdAt
      t.datetime :updatedAt

      t.timestamps
    end
  end
end
