class AddTaxExtras < ActiveRecord::Migration
  def self.up
    add_column :taxrates, :apl_storage, :boolean, :default => false
    create_table :extras_taxrates, :id => false do |t|
      t.integer :extra_id, :null => false
      t.integer :taxrate_id, :null => false
    end
    add_index :extras_taxrates, :extra_id
    add_index :extras_taxrates, :taxrate_id
    Extra.all.each do |e|
      Taxrate.all.each { |t| e.taxrates << t if t.is_percent } if e.taxable
    end
    remove_column :extras, :taxable
  end

  def self.down
    remove_column :taxrates, :apl_storage
    add_column :extras, :taxable, :boolean, :default => true
    Extra.all.each {|e| e.update_attributes :taxable => true if e.taxable }
    drop_table :extras_taxrates
  end
end
