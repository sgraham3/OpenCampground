class AddDeposit < ActiveRecord::Migration
  def self.up
    add_column :options, :deposit_type, :integer, :default => Remote::Full_charge
    add_column :options, :deposit, :decimal, :precision => 11, :scale => 5, :default => 0.0
  end

  def self.down
    remove_column :options, :deposit_type
    remove_column :options, :deposit
  end
end
