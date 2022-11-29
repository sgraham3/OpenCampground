class UpdateDs < ActiveRecord::Migration
  def self.up
    add_column :dynamic_strings, :updated_at, :datetime
  end

  def self.down
    remove_column :dynamic_strings, :updated_at
  end
end
