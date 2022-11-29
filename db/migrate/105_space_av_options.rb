class SpaceAvOptions < ActiveRecord::Migration
  
  def self.up
    add_column :options, :sa_font_size, :integer, :default => 13
  end

  def self.down
    remove_column :options, :sa_font_size
  end

end
