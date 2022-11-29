class EnhanceDiscounts < ActiveRecord::Migration
  def self.up
    add_column :discounts, :amount_daily, :decimal, :precision => 8, :scale => 2, :default => 0.0
    add_column :discounts, :amount_weekly, :decimal, :precision => 8, :scale => 2, :default => 0.0
    add_column :discounts, :amount_monthly, :decimal, :precision => 8, :scale => 2, :default => 0.0
  end

  def self.down
    remove_column :discounts, :amount_daily
    remove_column :discounts, :amount_weekly
    remove_column :discounts, :amount_monthly
  end
end
