class CreateLogs < ActiveRecord::Migration

  def self.up
    add_column :reservations, :cancelled, :boolean, :default => false
    add_column :reservations, :checked_out, :boolean, :default => false
    remove_column :options, :disp_log
  end

  def self.down
    add_column :options, :disp_log, :boolean, :default => false
    remove_column :reservations, :cancelled
    remove_column :reservations, :checked_out
  end
end
