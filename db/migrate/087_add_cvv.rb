class AddCvv < ActiveRecord::Migration
  def self.up
    add_column :card_transactions, :cvv2, :string, :default => ""
  end

  def self.down
    remove_column :card_transactions, :cvv2
  end
end
