class AddSitetypeTaxrates < ActiveRecord::Migration
  def self.up
    create_table :sitetypes_taxrates, :id => false do |t|
      t.integer :sitetype_id, :null => false
      t.integer :taxrate_id, :null => false
    end
    add_index :sitetypes_taxrates, :sitetype_id
    add_index :sitetypes_taxrates, :taxrate_id
    Sitetype.all.each do |s|
      Taxrate.all.each { |t| s.taxrates << t }
    end
  end

  def self.down
    drop_table :sitetypes_taxrates
  end
end
