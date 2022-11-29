class AddPrecision < ActiveRecord::Migration
  def self.up
    add_column :extra_charges, :precision, :integer, :default => 2
  end

  def self.down
    remove_column :extra_charges, :precision
  end
end
