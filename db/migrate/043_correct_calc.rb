class CorrectCalc < ActiveRecord::Migration
  def self.up
    Charge.find_all_by_charge_units(Charge::SEASON).each do |c|
      say "updating #{c.reservation_id}"
      begin
	@reservation = Reservation.find c.reservation_id
	unless @reservation.seasonal
	  Charges.new( @reservation.startdate,
			   @reservation.enddate,
			   @reservation.space.price.id,
			   @reservation.discount.id,
			   @reservation.id,
			   @reservation.seasonal)
	end
      rescue
        say "reservation #{c.reservation_id} not found"
      end
    end
  end

  def self.down
  end
end
