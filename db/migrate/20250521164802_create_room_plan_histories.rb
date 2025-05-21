class CreateRoomPlanHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :room_plan_histories do |t|
      t.integer :operationRoomId
      t.integer :planId
      t.datetime :startDate
      t.datetime :endDate
      t.datetime :createdAt

      t.timestamps
    end
  end
end
