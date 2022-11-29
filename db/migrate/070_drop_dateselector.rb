class DropDateselector < ActiveRecord::Migration
  def self.up
    remove_column :options, :use_calendar
    remove_column :options, :remote_embedded_calendar
    remove_column :options, :embedded_calendar
  end

  def self.down
    add_column :options, :use_calendar, :boolean, :default => false
    add_column :options, :remote_embedded_calendar, :boolean, :default => true
    add_column :options, :embedded_calendar, :boolean, :default => false
  end
end
