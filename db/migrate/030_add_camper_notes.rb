class AddCamperNotes < ActiveRecord::Migration
  def self.up
    add_column :campers, :notes, :text
  end

  def self.down
    remove_column :campers, :notes
  end
end
