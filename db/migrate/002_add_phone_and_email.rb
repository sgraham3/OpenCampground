class AddPhoneAndEmail < ActiveRecord::Migration
  def self.up
    add_column "campers", "phone", :string, :limit => 18
    add_column "campers", "email", :string, :limit => 128
    add_column "archives", "phone", :string, :limit => 18
    add_column "archives", "email", :string, :limit => 128
    Camper.reset_column_information
    Archive.reset_column_information
  end

  def self.down
    remove_column "campers", "phone"
    remove_column "campers", "email"
    remove_column "archives", "phone"
    remove_column "archives", "email"
  end
end
