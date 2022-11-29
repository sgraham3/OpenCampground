class MoreSizeChanges < ActiveRecord::Migration
  def self.up
    change_column :discounts, :amount_daily, :decimal, :precision => 11, :scale => 5, :default => 0.0
    change_column :discounts, :amount_weekly, :decimal, :precision => 11, :scale => 5, :default => 0.0
    change_column :discounts, :amount_monthly, :decimal, :precision => 12, :scale => 5, :default => 0.0
  end

  def self.down
    change_column :discounts, :amount_daily, :decimal, :precision => 8, :scale => 2, :default => 0.0
    change_column :discounts, :amount_weekly, :decimal, :precision => 8, :scale => 2, :default => 0.0
    change_column :discounts, :amount_monthly, :decimal, :precision => 8, :scale => 2, :default => 0.0
  end
end
