class AddToRates < ActiveRecord::Migration
  def self.up
    add_column :extras, :occasional, :boolean, :default => false
    add_column :extra_charges, :charge, :decimal, :precision => 8, :scale => 2, :default => 0.0
    ExtraCharge.all.each do |e|
      e.charge = e.onetime_charge if e.onetime_charge > 0
      e.charge = e.measured_charge if e.measured_charge > 0
    end
    remove_column :extra_charges, :onetime_charge
  rescue
  end

  def self.down
    remove_column :extras, :occasional
    add_column :extra_charges, :onetime_charge, :decimal, :precision => 8, :scale => 2, :default => 0.0
    ExtraCharge.all.each do |e|
      e.onetime_charge = e.charge if e.extra.onetime
      e.measured_charge = e.charge if e.extra.measured
    end
    remove_column :extra_charges, :charge
  end
end
