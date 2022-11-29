class UpdateArchives < ActiveRecord::Migration
  
  def self.up
    change_column :archives, :state, :string, :limit => 16
    change_column :archives, :extras, :text
  end

  def self.down
    change_column :archives, :state, :string, :limit => 4
    change_column :archives, :extras, :string
  end

end
