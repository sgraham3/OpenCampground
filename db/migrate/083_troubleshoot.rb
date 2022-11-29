class Troubleshoot < ActiveRecord::Migration
  def self.up
    add_column :options, :all_troubleshoot, :boolean, :default => false
  end

  def self.down
    remove_column :options, :all_troubleshoot
  end
end
