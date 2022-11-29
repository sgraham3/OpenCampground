class VariableRates < ActiveRecord::Migration
  def self.up
    add_column :options, :variable_rates, :boolean, :default => false
    add_column :rates, :sunday, :decimal, :precision => 6, :scale => 2, :default => 0.0, :null => false
    add_column :rates, :monday, :decimal, :precision => 6, :scale => 2, :default => 0.0, :null => false
    add_column :rates, :tuesday, :decimal, :precision => 6, :scale => 2, :default => 0.0, :null => false
    add_column :rates, :wednesday, :decimal, :precision => 6, :scale => 2, :default => 0.0, :null => false
    add_column :rates, :thursday, :decimal, :precision => 6, :scale => 2, :default => 0.0, :null => false
    add_column :rates, :friday, :decimal, :precision => 6, :scale => 2, :default => 0.0, :null => false
    add_column :rates, :saturday, :decimal, :precision => 6, :scale => 2, :default => 0.0, :null => false
    # make use of update configurable
    add_column :options, :use_update, :boolean, :default => true
    # optional credit card fees
    add_column :options, :use_cc_fee, :boolean, :default => true
    add_column :payments, :cc_fee, :decimal, :precision => 6, :scale => 2, :default => 0.0
  rescue
  end

  def self.down
    remove_column :options, :variable_rates
    remove_column :rates, :sunday
    remove_column :rates, :monday
    remove_column :rates, :tuesday
    remove_column :rates, :wednesday
    remove_column :rates, :thursday
    remove_column :rates, :friday
    remove_column :rates, :saturday
    remove_column :options, :use_update
    remove_column :options, :use_cc_fee
    remove_column :payments, :cc_fee
  end
end
