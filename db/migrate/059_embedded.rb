class Embedded < ActiveRecord::Migration
  def self.up
    add_column :options, :remote_embedded_calendar, :boolean, :default => true
    add_column :options, :embedded_calendar, :boolean, :default => false
  rescue
  end

  def self.down
    remove_column :options, :remote_embedded_calendar
    remove_column :options, :embedded_calendar
  end
end
