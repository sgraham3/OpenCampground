class AddManditoryRes < ActiveRecord::Migration
  
  def self.up
    add_column :options, :require_rigtype, :boolean, :default => false
    add_column :options, :require_length, :boolean, :default => false
    add_column :options, :require_age, :boolean, :default => false
  end

  def self.down
    remove_column :options, :require_rigtype
    remove_column :options, :require_length
    remove_column :options, :require_age
  end

end
