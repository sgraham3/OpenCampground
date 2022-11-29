class CreateMap < ActiveRecord::Migration
  def self.up
    add_column :options, :use_map, :boolean, :default => false
    add_column :options, :use_remote_map, :boolean, :default => false
    add_column :options, :map, :string
    add_column :options, :remote_map, :string
  end

  def self.down
    remove_column :options, :use_map
    remove_column :options, :use_remote_map
    remove_column :options, :map
    remove_column :options, :remote_map
  end

end
