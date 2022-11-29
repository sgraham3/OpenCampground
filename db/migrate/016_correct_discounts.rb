class CorrectDiscounts < ActiveRecord::Migration
  def self.up
    change_column "discounts", "discount_percent", :decimal, :precision => 5, :scale => 2, :default => 0.0
    change_column "reservations", "discount_percent", :decimal, :precision => 5, :scale => 2, :default => 0.0
  end

  def self.down
    change_column "discounts", "discount_percent", :decimal, :precision => 4, :scale => 2, :default => 0.0
    change_column "reservations", "discount_percent", :decimal, :precision => 4, :scale => 2, :default => 0.0
  end
end
