class AddResConfirmFlag < ActiveRecord::Migration
  def self.up
    add_column "reservations", "confirm", :boolean, :default => false
    Reservation.reset_column_information

    # set all current reservations to confirmed
    Reservation.find(:all).each do |r|
      r.update_attribute(:confirm, 'true')
    end

  end

  def self.down
    remove_column "reservations", "confirm"
  end
end
