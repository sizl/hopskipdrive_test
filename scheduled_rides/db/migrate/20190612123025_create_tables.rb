class CreateTables < ActiveRecord::Migration
  def change

    create_table :rides do |t|
      t.references :users, null: false
      t.references :drivers, null: false
      t.time :pickup_time, null: false
      t.string :start_address, null: false
      t.string :end_address, null: false
      t.string :start_location
      t.string :end_location
      t.decimal :distance
      t.datetime :start_at
      t.datetime :ended_at
      t.datetime :cancelled_at
      t.integer :scheduled_ride_id, null: true
      t.timestamps
    end

    create_table :scheduled_rides do |t|
      t.references :users, null: false
      t.string :name, null: false
      t.time :pickup_time, null: false
      t.string :start_address, null: false
      t.string :end_address, null: false
      t.string :repeat_type, null: false
      t.string :repeat_value, null: false
      t.datetime :ends_at, null: false
      t.timestamps
    end
  end
end
