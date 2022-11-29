require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  fixtures :groups
  fixtures :campers

  # create a record to compare to 
  def setup
    g = Group.new :name => 'validname', :camper_id => 1, :startdate => Date.today, :enddate => Date.tomorrow
    g.save
  end

  def test_presense_of_name
    # create without name
    group = Group.new :camper_id => 1, :startdate => Date.today, :enddate => Date.tomorrow
    assert !group.valid?
    assert group.errors.invalid?(:name)
    assert_equal 'can\'t be blank', group.errors.on(:name)
    # put on name
    group.name = "anything"
    # validate
    assert group.valid?
  end

  def test_uniqueness_of_name
    # create with reused name
    group = Group.new :name => 'validname', :camper_id => 1, :startdate => Date.today, :enddate => Date.tomorrow
    assert !group.valid?
    assert group.errors.invalid?(:name)
    # change the name
    group.name = 'anothername'
    assert group.valid?
  end

  def test_for_startdate
    group = Group.new :name => 'anothername', :camper_id => 1, :enddate => Date.tomorrow
    # test without startdate
    assert !group.valid?
    assert group.errors.invalid?(:startdate)
    group.startdate = Date.today
    # validate
    assert group.valid?
  end

  def test_for_enddate
    group = Group.new :name => 'anothername', :camper_id => 1, :startdate => Date.today
    # test without enddate
    assert !group.valid?
    assert group.errors.invalid?(:enddate)
    group.enddate = Date.tomorrow
    # validate
    assert group.valid?
  end

  def test_destroy
    group = Group.create :name => 'anothername', :camper_id => 1, :startdate => Date.today, :enddate => Date.tomorrow
    res = Reservation.create :camper_id => 1, :startdate => Date.today, :enddate => Date.today + 1, :group_id => group.id
    # can destroy with a reservation using the group
    # the reservation will now be in no group
    assert group.destroy
    res.reload
    assert res.group_id == 0
  end


end
