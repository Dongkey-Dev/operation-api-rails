class CreateApiV1CommandResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :api_v1_command_responses do |t|
      t.integer :commandId
      t.string :content
      t.string :responseType
      t.integer :priority
      t.boolean :isActive
      t.datetime :createdAt
      t.datetime :updatedAt
      t.boolean :isDeleted
      t.datetime :deletedAt

      t.timestamps
    end
  end
end
