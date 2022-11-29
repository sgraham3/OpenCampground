class Locale < ActiveRecord::Migration
  def self.up
    add_column :options, :locale, :string, :default => 'en', :limit => 16
  end

  def self.down
    remove_column :options, :locale
  end
end
