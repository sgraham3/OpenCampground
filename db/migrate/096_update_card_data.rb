class UpdateCardData < ActiveRecord::Migration
  def self.up
    add_column :card_transactions, :orderid, :string,  :limit => 20
    add_column :card_transactions, :bintype, :string,  :limit => 20
    add_column :card_transactions, :entrymode, :string,  :limit => 25
    add_column :card_transactions, :commcard, :string,  :limit => 2
    add_column :card_transactions, :emv, :text
    add_column :card_transactions, :emvTagData, :text
    add_column :card_transactions, :receiptData, :text
  end

  def self.down
    remove_column :card_transactions, :orderid
    remove_column :card_transactions, :bintype
    remove_column :card_transactions, :entrymode
    remove_column :card_transactions, :commcard
    remove_column :card_transactions, :emv
    remove_column :card_transactions, :emvTagData
    remove_column :card_transactions, :receiptData
  end
end
