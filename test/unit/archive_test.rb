require 'test_helper'

class ArchiveTest < ActiveSupport::TestCase
  fixtures :archives
  fixtures :reservations

  # see if we can archive a reservation
  def test_archive_record
    res = Reservation.find :first
    arc = Archive.archive_record res
    assert_kind_of Archive, arc
  end
end
