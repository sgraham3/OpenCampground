require 'test_helper'

class ReservationTest < ActiveSupport::TestCase
  fixtures :reservations, :taxrates, :prices, :seasons, :rates, :discounts, :options

  # Replace this with your real tests.
  def setup
    # get the first reservation 
    @reservation = Reservation.find("1")
  end

  def test_create
    ####
    # check data in first reservation
    ####
    assert_kind_of Reservation, @reservation
    assert_equal  1, @reservation.id
    assert_equal  Date.today-5, @reservation.startdate
    assert_equal  Date.today, @reservation.enddate
    assert_equal  7, @reservation.space_id
    assert_equal  true, @reservation.checked_in
    assert_equal  0, @reservation.deposit
    assert_equal  1, @reservation.camper_id
    assert_equal  2, @reservation.adults
    assert_equal  0, @reservation.kids
    assert_equal  0, @reservation.pets
    assert_equal  "Tent camper", @reservation.special_request
    assert_equal  "TX", @reservation.vehicle_state
    assert_equal  "XYZ123", @reservation.vehicle_license
    assert_equal  1, @reservation.discount_id
    assert_equal  nil, @reservation.group_id
    assert_equal  5, @reservation.rigtype_id
    assert_equal  0, @reservation.length
    assert_equal  0, @reservation.slides
    assert_equal  0, @reservation.rig_age
    assert_equal  0, @reservation.lock_version
  end
  #####################################
  # make sure get_charges returns
  # correct values
  #####################################
  def test_get_charges
  end

  def test_bad_camper
    assert_kind_of Reservation, @reservation
    @reservation.camper_id = nil
    @reservation.confirm = true
    assert !@reservation.valid?
    @reservation.camper_id = 0
    @reservation.confirm = true
    assert !@reservation.valid?
    @reservation.confirm = false
    assert @reservation.valid?
    @reservation.camper_id = 1
    assert @reservation.valid?
  end

  def test_dates
    @reservation = Reservation.new
    assert !@reservation.valid? # no startdate or enddate
    @reservation.startdate = Date.today
    assert !@reservation.valid? # no enddate
    @reservation.enddate = Date.tomorrow
    assert @reservation.valid? # now startdate and enddate
    @reservation.startdate = Date.tomorrow
    assert !@reservation.valid? # startdate == enddate
  end

  def test_no_conflicts
    # object method
    # create a reservation to test against
    Reservation.create! :space_id => 80, :startdate => Date.today - 2, :enddate => Date.today + 2, :confirm => true, :camper_id => 1
    # test 1 reservation starts and ends after enddate - no conflict
    r1 = Reservation.create! :startdate => Date.today + 3, :enddate => Date.today + 5, :space_id => 80, :confirm => true, :camper_id => 2
    assert r1.valid?
    assert !r1.conflicts?
    # test 2 reservation starts and ends before enddate - no conflict
    r1.update_attributes :startdate => Date.today - 6, :enddate => Date.today - 4
    assert r1.valid?
    assert !r1.conflicts?
    # test 3 reservation starts on enddate - no conflict
    r1.update_attributes :startdate => Date.today + 2, :enddate => Date.today + 4
    assert r1.valid?
    assert !r1.conflicts?
    # test 4 reservation ends on startdate - no conflict
    r1.update_attributes :startdate => Date.today - 6, :enddate => Date.today - 2
    assert r1.valid?
    assert !r1.conflicts?
  end

  def test_conflicts
    # object method
    # create a reservation to test against
    Reservation.create! :space_id => 80, :startdate => Date.today - 2, :enddate => Date.today + 2, :confirm => true, :camper_id => 1
    # test 5 reservation completely within - conflict
    r1 = Reservation.create! :space_id => 80, :startdate => Date.today - 1, :enddate => Date.today + 1, :confirm => true, :camper_id => 2
    assert !r1.valid?
    assert r1.conflicts?
    # test 6 reservation ends after startdate - conflict
    r1.update_attributes :startdate => Date.today - 6, :enddate => Date.today - 1
    assert !r1.valid?
    assert r1.conflicts?
    # test 7 reservation starts before enddate - conflict
    r1.update_attributes :startdate => Date.today + 1, :enddate => Date.today + 4
    assert !r1.valid?
    assert r1.conflicts?
  end

  def test_no_conflict
    # class method
    # create a reservation to test against
    Reservation.create! :space_id => 80, :startdate => Date.today - 2, :enddate => Date.today + 2, :confirm => true, :camper_id => 1
    # test 1 reservation starts and ends after enddate - no conflict
    r1 = Reservation.create! :startdate => Date.today + 3, :enddate => Date.today + 5, :space_id => 80, :confirm => true, :camper_id => 2
    assert r1.valid?
    assert !Reservation.conflict(r1)
    # test 2 reservation starts and ends before enddate - no conflict
    r1.update_attributes :startdate => Date.today - 6, :enddate => Date.today - 4
    assert r1.valid?
    assert !Reservation.conflict(r1)
    # test 3 reservation starts on enddate - no conflict
    r1.update_attributes :startdate => Date.today + 2, :enddate => Date.today + 4
    assert r1.valid?
    assert !Reservation.conflict(r1)
    # test 4 reservation ends on startdate - no conflict
    r1.update_attributes :startdate => Date.today - 6, :enddate => Date.today - 2
    assert r1.valid?
    assert !Reservation.conflict(r1)
    # test 5 starts on enddate - no conflict
    r1.update_attributes :startdate => Date.today + 2, :enddate => Date.today + 4
    assert r1.valid?
    assert !Reservation.conflict(r1)
    r1.update_attributes :startdate => Date.today + 1, :enddate => Date.today + 4
    assert !r1.valid?
    assert Reservation.conflict(r1)
    
  end

  def test_conflict
    # class method
    # create a reservation to test against
    Reservation.create! :space_id => 80, :startdate => Date.today - 2, :enddate => Date.today + 2, :confirm => true, :camper_id => 1
    # test 5 reservation completely within - conflict
    r1 = Reservation.create! :space_id => 80, :startdate => Date.today - 1, :enddate => Date.today + 1, :confirm => true, :camper_id => 2
    assert !r1.valid?
    assert Reservation.conflict(r1)
    # test 6 reservation ends after startdate - conflict
    r1.update_attributes :startdate => Date.today - 6, :enddate => Date.today - 1
    assert !r1.valid?
    assert Reservation.conflict(r1).class
    # test 7 reservation starts before enddate - conflict
    r1.update_attributes :startdate => Date.today + 1, :enddate => Date.today + 4
    assert !r1.valid?
    assert Reservation.conflict(r1).class
  end

  def test_checkout(options, user_login = nil)
    @reservation.update_attribute :checked_in, false
    assert !@reservation.checkout
    @reservation.update_attribute :checked_in, true
    assert @reservation.checkout
  end

# tests that need to be added

  def test_campground_open # half tested
  end

  def test_cancelled
    # just created, not cancelled
    assert !@reservation.cancelled?

    @reservation.update_attribute :log, 'made at: sometime<br/>'
    # reservation made... not cancelled
    assert !@reservation.cancelled?

    @reservation.update_attribute :cancelled, true
    # cancelled
    assert @reservation.cancelled?

    # reservation was cancelled and now undone so again not cancelled 
    @reservation.update_attribute :cancelled, false
    assert !@reservation.cancelled?
  end

  def test_checked_out
    # initially not checked out
    assert !@reservation.checked_out?

    @reservation.update_attribute :log, 'made at: sometime<br/>'
    # reservation made ... not checked out
    assert !@reservation.checked_out?

    @reservation.update_attribute :checked_out, true
    # checked out
    assert @reservation.checked_out?

    # reservation was checked out and now undone so again checked in
    @reservation.update_attribute :checked_out, false
    assert !@reservation.checked_out?
  end

  def test_editable?
    opt = Option.first
    opt.update_attribute :use_login, false
    @reservation.update_attribute :archived, true
    opt.update_attribute :edit_archives, false
    # archived and opt.edit_archives false so not editable
    assert !@reservation.editable?

    opt.update_attribute :edit_archives, true
    # archived and opt.edit_archives true so editable
    assert @reservation.editable?

    @reservation.update_attribute :archived, false
    # not archived so always editable
    assert @reservation.editable?
  end

  def test_before_update
  end

  def test_self_exists?(id)
  end

  def test_self_add_log(id = 0, msg = "", username = nil)
  end

  def test_add_log(msg = "", username = nil)
  end

  def test_archive
  end

  def test_get_charges (charges)
  end

  def test_get_possible_dates
  end

  def test_check_seasonal
  end

  def test_check_storage
  end

  def test_onetime_formatted=(str)
  end

  def test_onetime_formatted
  end


end
