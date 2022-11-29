class AddCancelDate < ActiveRecord::Migration
  def self.up
    add_column "archives", "canceled", :date
    Archive.reset_column_information
  end

  def self.down
    remove_column "archives", "canceled"
  end
end
