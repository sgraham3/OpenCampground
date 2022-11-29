class UpdateDb < ActiveRecord::Migration
  def self.up
    # change currency changes to accomodate more currencies
    change_column "archives", "deposit", :decimal, :precision => 8, :scale => 2, :default => 0.0
    change_column "archives", "total_charge", :decimal, :precision => 8, :scale => 2, :default => 0.0
    change_column "rates", "monthly_rate", :decimal, :precision => 7, :scale => 2, :default => 0.0
    change_column "reservations", "deposit", :decimal, :precision => 8, :scale => 2, :default => 0.0
    change_column "reservations", "total_charge", :decimal, :precision => 8, :scale => 2, :default => 0.0
    change_column "reservations", "monthly_rate", :decimal, :precision => 7, :scale => 2, :default => 0.0
    change_column "reservations", "month_charges", :decimal, :precision => 8, :scale => 2, :default => 0.0
    change_column "reservations", "day_charges", :decimal, :precision => 8, :scale => 2, :default => 0.0
    change_column "reservations", "week_charges", :decimal, :precision => 8, :scale => 2, :default => 0.0
    change_column "reservations", "total", :decimal, :precision => 8, :scale => 2, :default => 0.0
    # expand handling of payment types
    add_column "creditcards", "is_credit_card", :boolean, :default => true
    add_column "creditcards", "validate_cc_number", :boolean, :default => false
    add_column "creditcards", "use_expiration", :boolean, :default => false
    add_column "creditcards", "validate_expiration", :boolean, :default => false
    add_column "reservations", "cc_expire", :date
    add_column "creditcards", "use_cvv2", :boolean, :default => false
    add_column "reservations", "cvv2", :integer
    #add log
    add_column "reservations", "log", :text
    add_column "archives", "log", :text
    # enhance handling of displays
    add_column "options", "sa_columns", :integer, :default => 120
    add_column "options", "max_spacename", :integer, :default => 3
    add_column "options", "disp_rows", :integer, :default => 12
    add_column "options", "disp_log", :boolean, :default => false
    add_column "options", "find_by_id", :boolean, :default => false
    Archive.reset_column_information
    Rate.reset_column_information
    Reservation.reset_column_information
    Creditcard.reset_column_information
    Option.reset_column_information
    begin
      o = Option.find :first
      Space.find(:all).each do |s|
	o.max_spacename = s.name_size(o.max_spacename)
      end
      o.save
    rescue
    end
  end

  def self.down
    change_column "archives", "deposit", :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column "archives", "total_charge", :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column "rates", "monthly_rate", :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column "reservations", "deposit", :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column "reservations", "total_charge", :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column "reservations", "monthly_rate", :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column "reservations", "month_charges", :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column "reservations", "day_charges", :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column "reservations", "week_charges", :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column "reservations", "total", :decimal, :precision => 6, :scale => 2, :default => 0.0
    remove_column "creditcards", "is_credit_card"
    remove_column "creditcards", "validate_cc_number"
    remove_column "creditcards", "use_expiration"
    remove_column "reservations", "cc_expire"
    remove_column "creditcards", "validate_expiration"
    remove_column "creditcards", "use_cvv2"
    remove_column "reservations", "cvv2"
    remove_column "reservations", "log"
    remove_column "archives", "log"
    remove_column "options", "sa_columns"
    remove_column "options", "max_spacename"
    remove_column "options", "disp_rows"
    remove_column "options", "disp_log"
    remove_column "options", "find_by_id"
  end
end
