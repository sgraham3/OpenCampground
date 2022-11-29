class CreateCountries < ActiveRecord::Migration

  class Country < ActiveRecord::Base; end

  def self.up
    create_table :countries do |t|
      t.string :name, :limit => 20
      t.timestamps
    end
    rename_column :campers, :country, :country_name
    add_column :campers, :country_id, :integer, :default => 0
    Camper.reset_column_information

    Country.new(:name => nil).save
    Camper.find(:all).each do |camper|
      c = Country.find_by_name camper.country_name
      if c == nil
	n = Country.new :name => camper.country_name
	n.save
	camper.country_id = n.id
      else
	camper.country_id = c.id
      end
      camper.save
    end
    remove_column :campers, :country_name
    Camper.reset_column_information
  end

  def self.down
    add_column :campers, :country_name, :string, :limit => 16
    Camper.reset_column_information
    Camper.find(:all).each do |camper|
      unless camper.country == 0
	camper.country_name = camper.country.name
	camper.save
      end
    end
    drop_table :countries
    remove_column :campers, :country_id
    rename_column :campers, :country_name, :country
  end
end
