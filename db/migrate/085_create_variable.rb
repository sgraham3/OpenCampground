class CreateVariable < ActiveRecord::Migration
  def self.up
    add_column :options, :use_variable_charge, :boolean, :default => false
    add_column :options, :all_manage_variable, :boolean, :default => true
    create_table :variable_charges do |t|
      t.integer	:reservation_id
      t.string :detail
      t.decimal :amount, :precision => 12, :scale => 2, :default => 0.0
      t.boolean :taxable, :null => false, :default => true
      t.timestamps
    end
    create_table :taxrates_variable_charges, :id => false do |t|
      t.integer :variable_charge_id, :null => false
      t.integer :taxrate_id, :null => false
    end
    add_index :taxrates_variable_charges, :variable_charge_id
    add_index :taxrates_variable_charges, :taxrate_id
  end

  def self.down
    remove_column :options, :use_variable_charge
    remove_column :options, :all_manage_variable
    drop_table :variable_charges
    drop_table :taxrates_variable_charges
  end
end
