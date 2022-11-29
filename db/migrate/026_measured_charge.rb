class MeasuredCharge < ActiveRecord::Migration
  def self.up
    # measured
    # a retained value in spaces
    add_column :spaces, :current, :decimal, :precision => 8, :scale => 2, :default => 0.0
    # something on extras
    add_column :extras, :measured, :boolean, :default => false
    add_column :extras, :rate, :decimal, :precision => 10, :scale => 4, :default => 0.0
    add_column :extras, :unit_name, :text
    # some on extra_charges
    add_column :extra_charges, :initial, :decimal, :precision => 8, :scale => 2, :default => 0.0
    add_column :extra_charges, :final, :decimal, :precision => 8, :scale => 2, :default => 0.0
    add_column :extra_charges, :measured_charge, :decimal, :precision => 8, :scale => 2, :default => 0.0
    add_column :extra_charges, :updated_on, :date
  end

  def self.down
    # measured
    remove_column :spaces, :current
    remove_column :extras, :measured
    remove_column :extras, :rate
    remove_column :extras, :unit_name
    remove_column :extra_charges, :initial
    remove_column :extra_charges, :final
    remove_column :extra_charges, :measured_charge
    remove_column :extra_charges, :updated_on
  end
end
