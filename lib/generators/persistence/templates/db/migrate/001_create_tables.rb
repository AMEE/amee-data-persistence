class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :calculations do |t|
      t.string  "profile_uid"
      t.string  "profile_item_uid"
      t.string  "calculation_type"

      t.timestamps
    end

    create_table :terms do |t|
      t.integer  "calculation_id"
      t.string  "label"
      t.string  "value"

      t.timestamps
    end
  end

  def self.down
    drop_table :calculations
    drop_table :terms
  end
end
