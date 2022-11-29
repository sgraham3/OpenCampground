class AddCancel < ActiveRecord::Migration
  
  def self.up
    add_column :reservations, :cancel_charge, :decimal, :precision => 10, :scale => 5, :default => 0.0, :null => false
  end

  def self.down
    remove_column :reservations, :cancel_charge
  end

end
