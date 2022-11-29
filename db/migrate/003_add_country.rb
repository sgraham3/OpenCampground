class AddCountry < ActiveRecord::Migration
  class Option < ActiveRecord::Base; end

  def self.up
    create_table "options" do |t|
      t.column "use_country", :boolean, :default => false
    end

    say "setting option to not use country"
    country = Option.create(:use_country => 'false')
    country.save
    
    add_column "campers", "country", :string, :limit => 16
    add_column "archives", "country", :string, :limit => 16
    Camper.reset_column_information
    Archive.reset_column_information
  end

  def self.down
    drop_table :options
    remove_column "campers", "country"
    remove_column "archives", "country"
  end
end
