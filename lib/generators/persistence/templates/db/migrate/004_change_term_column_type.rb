class ChangeTermColumnType < ActiveRecord::Migration
  def self.up
    remove_index :terms, :name => "label_name_calc_id_index"
    change_column :terms, :value, :text
    execute "CREATE INDEX `label_value_calc_id_index` ON `terms` (label, value(20), calculation_id)"
  end

  def self.down
    remove_index :terms, :name => "label_value_calc_id_index"
    change_column :terms, :value, :string
    add_index "terms", ["label", "value", "calculation_id"], :name => "label_name_calc_id_index"
  end
end
