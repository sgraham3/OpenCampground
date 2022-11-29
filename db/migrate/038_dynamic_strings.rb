class DynamicStrings < ActiveRecord::Migration
  def self.up
    remove_column :options, :css
    add_column :options, :css, :text
    change_column :options, :js, :text
    change_column :options, :remote_css, :text
    change_column :options, :remote_js, :text
    create_table :dynamic_strings do |t|
      t.string :name
      t.binary :text
    end
    add_index :dynamic_strings, :name
  end

  def self.down
    change_column :options, :css, :string
    change_column :options, :js, :string
    change_column :options, :remote_css, :string
    change_column :options, :remote_js, :string
    remove_index :dynamic_strings, :name
    drop_table :dynamic_strings
  end
end
