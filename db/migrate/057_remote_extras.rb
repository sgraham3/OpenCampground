class RemoteExtras < ActiveRecord::Migration
  def self.up
    add_column :extras, :remote_display, :boolean, :default => true
    Extra.all.each {|e| e.update_attribute(:remote_display, false) if e.extra_type == Extra::MEASURED }
  end

  def self.down
    remove_column :extras, :remote_display
  end
end
