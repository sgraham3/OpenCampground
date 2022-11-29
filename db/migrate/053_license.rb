class License < ActiveRecord::Migration
  def self.up
    add_column :options, :use_license, :boolean, :default => false
  end

  def self.down
    add_column :options, :use_license
  end
end
