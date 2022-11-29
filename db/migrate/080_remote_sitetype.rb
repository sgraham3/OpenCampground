class RemoteSitetype < ActiveRecord::Migration

  def self.up
    add_column :options, :use_remote_sitetype, :boolean, :default => true
  end

  def self.down
    remove_column :options, :use_remote_sitetype
  end
end
