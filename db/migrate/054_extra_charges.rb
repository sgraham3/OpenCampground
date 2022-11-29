class ExtraCharges < ActiveRecord::Migration
  def self.up
    add_column :extra_charges, :created_on, :date
    ExtraCharge.all.each {|e| e.update_attribute :created_on, e.updated_on}
  end

  def self.down
    remove_column :extra_charges, :created_on
  end
end
