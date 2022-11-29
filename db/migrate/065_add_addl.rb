class AddAddl < ActiveRecord::Migration
  def self.up
    add_column :campers, :addl, :text
    add_column :options, :use_addl, :boolean, :default => false
  end

  def self.down
    remove_column :campers, :addl
    remove_column :options, :use_addl
  end
end
