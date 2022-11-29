class MvChargesToRes < ActiveRecord::Migration
  def self.up
    add_column "reservations", "days",  :integer, :default => 0
    add_column "reservations", "daily_rate",  :integer, :default => 0
    add_column "reservations", "daily_disc",  :integer, :default => 0
    add_column "reservations", "day_charges",  :integer, :default => 0

    add_column "reservations", "weeks",  :integer, :default => 0
    add_column "reservations", "weekly_rate",  :integer, :default => 0
    add_column "reservations", "weekly_disc",  :integer, :default => 0
    add_column "reservations", "week_charges",  :integer, :default => 0

    add_column "reservations", "months",  :integer, :default => 0
    add_column "reservations", "monthly_rate",  :integer, :default => 0
    add_column "reservations", "monthly_disc",  :integer, :default => 0
    add_column "reservations", "month_charges",  :integer, :default => 0

    add_column "reservations", "discount_name",  :string, :limit => 24, :default => ""
    add_column "reservations", "discount_percent",  :integer, :default => 0

    add_column "reservations", "sales_tax", :integer, :default => 0
    add_column "reservations", "sales_tax_str", :string, :limit => 24, :default => ""
    add_column "reservations", "local_tax", :integer, :default => 0
    add_column "reservations", "local_tax_str", :string, :limit => 24, :default => ""
    add_column "reservations", "room_tax", :integer, :default => 0
    add_column "reservations", "room_tax_str", :string, :limit => 24, :default => ""
    add_column "reservations", "total", :integer, :default => 0
    Reservation.reset_column_information
  end

#
# need to add something here to populate the database with data for 
# current reservations where checked_in is false
#


  def self.down

    remove_column "reservations", "days"
    remove_column "reservations", "daily_rate"
    remove_column "reservations", "daily_disc"
    remove_column "reservations", "day_charges"

    remove_column "reservations", "weeks"
    remove_column "reservations", "weekly_rate"
    remove_column "reservations", "weekly_disc"
    remove_column "reservations", "week_charges"

    remove_column "reservations", "months"
    remove_column "reservations", "monthly_rate"
    remove_column "reservations", "monthly_disc"
    remove_column "reservations", "month_charges"

    remove_column "reservations", "discount_name"
    remove_column "reservations", "discount_percent"

    remove_column "reservations", "sales_tax"
    remove_column "reservations", "sales_tax_str"
    remove_column "reservations", "local_tax"
    remove_column "reservations", "local_tax_str"
    remove_column "reservations", "room_tax"
    remove_column "reservations", "room_tax_str"
    remove_column "reservations", "total"

  end
end
