class CorrectStatus < ActiveRecord::Migration

  def self.up
  # get checked_out and cancelled in sync with data from log
    Reservation.all.each do |r|
      r.update_attribute :checked_out, true if r._checked_out?
      r.update_attribute :cancelled, true if r._cancelled?
    end
  end

  def self.down
  # nothing to be done
  end
end
