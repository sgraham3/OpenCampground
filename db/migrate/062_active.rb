class Active < ActiveRecord::Migration
  def self.up
    add_column :countries, :active, :boolean, :default => true
    add_column :discounts, :active, :boolean, :default => true
    add_column :extras, :active, :boolean, :default => true
    add_column :creditcards, :active, :boolean, :default => true
    add_column :recommenders, :active, :boolean, :default => true
    add_column :seasons, :active, :boolean, :default => true
    add_column :sitetypes, :active, :boolean, :default => true
    add_column :spaces, :active, :boolean, :default => true
    add_column :rigtypes, :active, :boolean, :default => true
    add_column :taxrates, :active, :boolean, :default => true
  end

  def self.down
    remove_column :countries, :active
    remove_column :discounts, :active
    remove_column :extras, :active
    remove_column :creditcards, :active
    remove_column :recommenders, :active
    remove_column :seasons, :active
    remove_column :sitetypes, :active
    remove_column :spaces, :active
    remove_column :rigtypes, :active
    remove_column :taxrates, :active
  end
end
