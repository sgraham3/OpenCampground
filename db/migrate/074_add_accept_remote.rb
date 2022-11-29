class AddAcceptRemote < ActiveRecord::Migration
  def self.up
    add_column :options, :remote_auto_accept, :boolean, :default => false
  end

  def self.down
    remove_column :options, :remote_auto_accept
  end
end
