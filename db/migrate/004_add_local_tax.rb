class AddLocalTax < ActiveRecord::Migration
  class Sitetype < ActiveRecord::Base; end

  def self.up
    add_column "taxes", "lt_apl_week",  :boolean, :default => true
    add_column "taxes", "lt_apl_month", :boolean, :default => true
    
    # put in an initial entry for sitetypes
    basic = Sitetype.create(:name => 'basic')
    basic.save
    Tax.reset_column_information
  end

  def self.down
    remove_column "taxes", "lt_apl_week"
    remove_column "taxes", "lt_apl_month"
  end
end
