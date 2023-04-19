class AddEventsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :customer_id
      t.string :event_code, null: false
      t.string :event_id, null: false
      t.datetime :timestamp
      t.jsonb 'properties'
      t.timestamps

      t.index :event_id, unique: true
    end
  end
end
