require 'test_helper'

class SpaceTest < ActiveSupport::TestCase
  fixtures :spaces
  fixtures :reservations

  # create a record to compare to 
  def setup
    space = Space.new :name => 'validname'
    space.save
  end

  # get tent spaces
  def test_01
    s=Space.available Date.today, Date.today+1, 1
    assert_equal 3, s.size
  end
  def test_01a
    s=Space.available Date.today, Date.today+2, 1
    assert_equal 2, s.size
  end
  def test_01b
    s=Space.available Date.today, Date.today+3, 1
    assert_equal 2, s.size
  end
  def test_01c
    s=Space.available Date.today, Date.today+4, 1
    assert_equal 2, s.size
  end
  def test_01d
    s=Space.available Date.today, Date.today+5, 1
    assert_equal 1, s.size
  end

  # get regular spaces
  def test_02
    s=Space.available Date.today, Date.today+1, 2
    assert_equal 9, s.size
  end
  def test_02a
    s=Space.available Date.today, Date.today+6, 2
    assert_equal 5, s.size
  end

  # get premium spaces
  def test_03
    s=Space.available Date.today, Date.today+1, 3
    assert_equal 2, s.size
  end
  def test_03a
    s=Space.available Date.today, Date.today+2, 3
    assert_equal 1, s.size
  end
  def test_03b
    s=Space.available Date.today, Date.today+3, 3
    assert_equal 0, s.size
  end

  def test_04
    # get all spaces
    s=Space.available Date.today, Date.today+1
    assert_equal 15, s.size
  end

  def test_ews
    s=Space.new  :name => 't1', :power_30a => true, :water => false, :sewer => true
    assert_equal 'ES 30A', s.ews
  end

  def test_presense_of_name
    # create without name
    space = Space.new
    assert !space.valid?
    assert space.errors.invalid?(:name)
    # put on name
    space.name = "anything"
    # validate with name
    assert space.valid?
  end

  def test_uniqueness_of_name
    # create with reused name
    space = Space.new :name => 'validname'
    assert !space.valid?
    assert space.errors.invalid?(:name)
    # change the name
    space.name = 'anothername'
    assert space.valid?
  end

  def test_for_occupancy
    r=Reservation.find 2
    assert r.space.occupied # reservation 2 is checked in
    r.update_attribute :archived, true
    assert !r.space.occupied # reservation 2 is archived
    r=Reservation.find 8
    assert !r.space.occupied # reservation 8 is not checked in
  end

  def test_remote
    # site 90 is not remotly reservable
    s=Space.available_remote Date.today, Date.today+1, 1
    assert_equal 2, s.size

    # site 20 is not remotley reservable
    s=Space.available_remote Date.today, Date.today+1, 2
    assert_equal 8, s.size

    # get all spaces, 20 and 90 should not be reservable
    s=Space.available_remote Date.today, Date.today+1
    assert_equal 13, s.size
  end

  def test_confirm_availability
    res1 = Reservation.create! :space_id => 25, :startdate => Date.today, :enddate => Date.today + 5
    # should succeed starting on last day end later
    s = Space.confirm_available res1.id + 1, 25, Date.today + 5, Date.today + 7
    assert_equal 0, s.size
    # should succeed start early end on startdate
    s = Space.confirm_available res1.id + 1, 25, Date.today - 5, Date.today
    assert_equal 0, s.size
    # should fail start early end 1 day in -- bad enddate
    s = Space.confirm_available res1.id + 1, 25, Date.today - 5, Date.today + 1
    assert_equal 1, s.size
    # should fail start early end after enddate -- spans
    s = Space.confirm_available res1.id + 1, 25, Date.today - 5, Date.today + 7
    assert_equal 1, s.size
    # should fail start 1 day in end later -- bad startdate
    s = Space.confirm_available res1.id + 1, 25, Date.today + 1, Date.today + 7
    assert_equal 1, s.size
    # should fail starting on same, end in period -- bad enddate
    s = Space.confirm_available res1.id + 1, 25, Date.today, Date.tomorrow
    assert_equal 1, s.size
    # should fail starting in period, end later -- bad startdate
    s = Space.confirm_available res1.id + 1, 25, Date.today + 4, Date.today + 7
    assert_equal 1, s.size
  end

end
