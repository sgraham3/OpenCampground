class FontOptions < ActiveRecord::Migration
  
  def self.up
    add_column :options, :font_family, :string, :default => 'serif'
    add_column :options, :font_size, :integer, :default => 9
  end

  def self.down
    remove_column :options, :font_family
    remove_column :options, :font_size
  end

end
