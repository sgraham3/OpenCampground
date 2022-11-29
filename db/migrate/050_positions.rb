class Positions < ActiveRecord::Migration
  def self.up
    add_column :extras, :position, :integer
    add_index  :extras, :position
    Extra.all.each do |ex|
      ex.update_attribute :position, ex.id
    end
    add_column :discounts, :position, :integer
    add_index  :discounts, :position
    Discount.all.each do |d|
      d.update_attribute :position, d.id
    end
    add_column :countries, :position, :integer
    add_index  :countries, :position
    Country.all.each do |d|
      d.update_attribute :position, d.id
    end
    add_column :creditcards, :position, :integer
    add_index  :creditcards, :position
    Creditcard.all.each do |d|
      d.update_attribute :position, d.id
    end
    add_column :recommenders, :position, :integer
    add_index  :recommenders, :position
    Recommender.all.each do |d|
      d.update_attribute :position, d.id
    end
    add_column :rigtypes, :position, :integer
    add_index  :rigtypes, :position
    Rigtype.all.each do |d|
      d.update_attribute :position, d.id
    end
    add_column :sitetypes, :position, :integer
    add_index  :sitetypes, :position
    Sitetype.all.each do |d|
      d.update_attribute :position, d.id
    end
    add_column :taxrates, :position, :integer
    add_index  :taxrates, :position
    Taxrate.all.each do |d|
      d.update_attribute :position, d.id
    end
  end

  def self.down
    remove_column :extras, :position
    remove_index  :extras, :position
    remove_column :discounts, :position
    remove_index  :discounts, :position
    remove_column :countries, :position
    remove_index  :countries, :position
    remove_column :creditcards, :position
    remove_index  :creditcards, :position
    remove_column :recommenders, :position
    remove_index  :recommenders, :position
    remove_column :rigtypes, :position
    remove_index  :rigtypes, :position
    remove_column :sitetypes, :position
    remove_index  :sitetypes, :position
    remove_column :taxrates, :position
    remove_index  :taxrates, :position
  end
end
