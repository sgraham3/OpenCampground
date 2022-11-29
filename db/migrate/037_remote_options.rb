class RemoteOptions < ActiveRecord::Migration
  def self.up
    add_column :options, :require_email, :boolean, :default => false
    add_column :options, :require_phone, :boolean, :default => false
    add_column :versions, :install_pending, :boolean, :default => true
  end

  def self.down
    remove_column :options, :require_email
    remove_column :options, :require_phone
    remove_column :versions, :install_pending
  end
end
