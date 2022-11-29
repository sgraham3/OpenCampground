class AddOptions < ActiveRecord::Migration
  def self.up
    change_column "reservations", "credit_card_no", :string, :limit => 20, :default => ""
    # feature request 25813 
    add_column "options", "use_id", :boolean, :default => false
    add_column "campers", "idnumber", :string, :limit => 24
    add_column "archives", "idnumber", :string, :limit => 24
    # feature request 25828
    add_column "options", "unit", :string, :limit => 12, :default => "$"
    add_column "options", "separator", :string, :limit => 2, :default => "."
    add_column "options", "delimiter", :string, :limit => 2, :default => ","
    # 
    add_column "options", "header", :string
    add_column "options", "trailer", :string
    Option.reset_column_information
    Reservation.reset_column_information
    Camper.reset_column_information
    Archive.reset_column_information
  end

  def self.down
    change_column "reservations", "credit_card_no", :decimal, :precision => 6, :scale => 2, :default => 0.0
    # feature request 25813 
    remove_column "options", "use_id"
    remove_column "campers", "idnumber"
    remove_column "archives", "idnumber"
    # feature request 25828
    remove_column "options", "unit"
    remove_column "options", "separator"
    remove_column "options", "delimiter"
    # 
    remove_column "options", "header"
    remove_column "options", "trailer"
  end
end
