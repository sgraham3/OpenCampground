class CreateRefundable < ActiveRecord::Migration
  
  def self.up
    add_column :payments, :refundable, :boolean, :default => false
  end

  def self.down
    remove_column :payments, :refundable
  end

end
