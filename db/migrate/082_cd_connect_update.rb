class CdConnectUpdate < ActiveRecord::Migration
  def self.up
    add_column :card_transactions, :process_mode, :integer
  end

  def self.down
    remove_column :card_transactions, :process_mode
  end
end
