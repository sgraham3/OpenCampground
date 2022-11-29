class Archives < ActiveRecord::Migration
  def self.up
    add_column :options, :edit_archives, :boolean, :default => true
    add_column :options, :all_edit_archives, :boolean, :default => false
    Color.create!(:name => 'hover', :value => 'LightGray')
  rescue
  end

  def self.down
    remove_column :options, :edit_archives
    remove_column :options, :all_edit_archives
  end
end
