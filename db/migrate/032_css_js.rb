class CssJs < ActiveRecord::Migration
  def self.up
    add_column :options, :css, :string
    add_column :options, :js, :string
    add_column :options, :remote_css, :string
    add_column :options, :remote_js, :string
  rescue
  end

  def self.down
    remove_column :options, :css
    remove_column :options, :js
    remove_column :options, :remote_css
    remove_column :options, :remote_js
  end
end
