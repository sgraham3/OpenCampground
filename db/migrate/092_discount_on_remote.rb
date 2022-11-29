class DiscountOnRemote < ActiveRecord::Migration
  def self.up
    add_column :discounts, :show_on_remote, :boolean, :default => true
  end

  def self.down
    remove_column :discounts, :show_on_remote
  end
end
