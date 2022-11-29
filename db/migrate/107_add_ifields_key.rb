class AddIfieldsKey < ActiveRecord::Migration
  def self.up
    begin
      add_column :integrations, :ck_ifields_key, :string
      add_column :integrations, :ck_use_terminal, :boolean, :default => false
    rescue # ignore the error, column already there
    end
  end

  def self.down
    remove_column :integrations, :ck_ifields_key, :string
    remove_column :integrations, :ck_use_terminal
  end
end
