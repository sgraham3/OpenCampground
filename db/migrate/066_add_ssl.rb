class AddSsl < ActiveRecord::Migration
  def self.up
    add_column :options, :use_ssl, :boolean, :default => false
  end

  def self.down
    remove_column :options, :use_ssl
  end
end
