class UpdateDb19 < ActiveRecord::Migration
  def self.up
    rename_column :extra_charges, :count, :number
  end

  def self.down
    rename_column :extra_charges, :number, :count
  end
end
