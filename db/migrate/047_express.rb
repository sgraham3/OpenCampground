class Express < ActiveRecord::Migration
  def self.up
    add_column :options, :express,      :boolean, :default => false
    add_column :options, :use_discount, :boolean, :default => true
  end

  def self.down
    remove_column :options, :express
    remove_column :options, :use_discount
  end
end
