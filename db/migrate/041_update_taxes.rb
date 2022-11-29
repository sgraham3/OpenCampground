class UpdateTaxes < ActiveRecord::Migration
  def self.up
    add_column :options, :rates_decimal, :integer, :default => 2
    add_column :taxrates, :weekly_charge_daily, :boolean, :default => true
    add_column :taxrates, :monthly_charge_daily, :boolean, :default => true
    add_column :taxrates, :seasonal_charge_daily, :boolean, :default => true
    change_column :rates, :daily_rate, :decimal, :precision => 10, :scale => 5, :default => 0.0
    change_column :rates, :weekly_rate, :decimal, :precision => 10, :scale => 5, :default => 0.0
    change_column :rates, :monthly_rate, :decimal, :precision => 11, :scale => 5, :default => 0.0
    change_column :rates, :sunday, :decimal, :precision => 10, :scale => 5, :default => 0.0
    change_column :rates, :monday, :decimal, :precision => 10, :scale => 5, :default => 0.0
    change_column :rates, :tuesday, :decimal, :precision => 10, :scale => 5, :default => 0.0
    change_column :rates, :wednesday, :decimal, :precision => 10, :scale => 5, :default => 0.0
    change_column :rates, :thursday, :decimal, :precision => 10, :scale => 5, :default => 0.0
    change_column :rates, :friday, :decimal, :precision => 10, :scale => 5, :default => 0.0
    change_column :rates, :saturday, :decimal, :precision => 10, :scale => 5, :default => 0.0
    change_column :payments, :amount, :decimal, :precision => 11, :scale => 5, :default => 0.0
  end

  def self.down
    remove_column :options, :rates_decimal
    remove_column :taxrates, :weekly_charge_daily
    remove_column :taxrates, :monthly_charge_daily
    remove_column :taxrates, :seasonal_charge_daily
    change_column :rates, :daily_rate, :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column :rates, :weekly_rate, :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column :rates, :monthly_rate, :decimal, :precision => 7, :scale => 2, :default => 0.0
    change_column :rates, :sunday, :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column :rates, :monday, :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column :rates, :tuesday, :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column :rates, :wednesday, :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column :rates, :thursday, :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column :rates, :friday, :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column :rates, :saturday, :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column :payments, :amount, :decimal, :precision => 8, :scale => 2, :default => 0.0
  end
end
