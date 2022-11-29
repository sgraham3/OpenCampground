class MoreMatches < ActiveRecord::Migration
  def self.up
    add_column :options, :match_firstname, :boolean, :default => false
    add_column :options, :match_city, :boolean, :default => false
  end

  def self.down
    remove_column :options, :match_firstname
    remove_column :options, :match_city
  end
end
