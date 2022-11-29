class Conflict < ActiveRecord::Base
  include MyLib

  def self.double_booking
    # check for conflicts aka double booking
    double = Array.new
    res = Reservation.all( :conditions => [ "(enddate >= ? or checked_in = ?) and confirm = ? and archived = ?",Date.current, true, true, false])

    res.each do |r|
      sp = Space.confirm_available r.id, r.space_id, r.startdate, r.enddate
      if sp.size > 0
        sp.each do |s|
	  next if r.id > s.id
	  double << { "first" => r.id, "second" => s.id}
        end
      end
    end
    return double
  end

  def self.test_double_booking
    # check for conflicts aka double booking
    double = Array.new
    double << { "first" => 7, "second" => 8}
    return double
  end

end
