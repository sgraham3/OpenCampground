require 'test_helper'

class SeasonTest < ActiveSupport::TestCase
  fixtures :seasons

  def test_find_by_date
    assert_equal "default", Season.find_by_date('2009-05-31').name
    assert_equal "summer", Season.find_by_date('2009-06-01').name
    assert_equal "summer", Season.find_by_date('2009-06-02').name
    assert_equal "summer", Season.find_by_date('2009-06-30').name
    assert_equal "holiday1", Season.find_by_date('2009-07-01').name
    assert_equal "holiday1", Season.find_by_date('2009-07-04').name
    assert_equal "holiday1", Season.find_by_date('2009-07-06').name
    assert_equal "summer", Season.find_by_date('2009-07-07').name
    assert_equal "summer", Season.find_by_date('2009-08-28').name
    assert_equal "holiday2", Season.find_by_date('2009-08-29').name
    assert_equal "holiday2", Season.find_by_date('2009-09-01').name
    assert_equal "holiday2", Season.find_by_date('2009-09-04').name
    assert_equal "default", Season.find_by_date('2009-09-05').name
  end

  def test_find_weekly_by_date
    assert_equal "default", Season.find_weekly_by_date('2009-05-31').name
    assert_equal "summer", Season.find_weekly_by_date('2009-06-01').name
    assert_equal "summer", Season.find_weekly_by_date('2009-06-02').name
    assert_equal "summer", Season.find_weekly_by_date('2009-06-30').name
    assert_equal "summer", Season.find_weekly_by_date('2009-07-01').name
    assert_equal "summer", Season.find_weekly_by_date('2009-07-04').name
    assert_equal "summer", Season.find_weekly_by_date('2009-07-06').name
    assert_equal "summer", Season.find_weekly_by_date('2009-07-07').name
    assert_equal "summer", Season.find_weekly_by_date('2009-08-28').name
    assert_equal "holiday2", Season.find_weekly_by_date('2009-08-29').name
    assert_equal "holiday2", Season.find_weekly_by_date('2009-09-01').name
    assert_equal "holiday2", Season.find_weekly_by_date('2009-09-04').name
    assert_equal "default", Season.find_weekly_by_date('2009-09-05').name
  end

  def test_find_monthly_by_date
    assert_equal "default", Season.find_monthly_by_date('2009-05-31').name
    assert_equal "summer", Season.find_monthly_by_date('2009-06-01').name
    assert_equal "summer", Season.find_monthly_by_date('2009-06-02').name
    assert_equal "summer", Season.find_monthly_by_date('2009-06-30').name
    assert_equal "holiday1", Season.find_monthly_by_date('2009-07-01').name
    assert_equal "holiday1", Season.find_monthly_by_date('2009-07-04').name
    assert_equal "holiday1", Season.find_monthly_by_date('2009-07-06').name
    assert_equal "summer", Season.find_monthly_by_date('2009-07-07').name
    assert_equal "summer", Season.find_monthly_by_date('2009-08-28').name
    assert_equal "summer", Season.find_monthly_by_date('2009-08-29').name
    assert_equal "default", Season.find_monthly_by_date('2009-09-01').name
    assert_equal "default", Season.find_monthly_by_date('2009-09-04').name
    assert_equal "default", Season.find_monthly_by_date('2009-09-05').name
  end

  def test_presense_of_name_and_dates
    # create without name, startdate or enddate
    season = Season.new
    assert !season.valid?
    assert season.errors.invalid?(:name)
    assert season.errors.invalid?(:startdate)
    assert season.errors.invalid?(:enddate)
    # put on name
    season.name = "anything"
    season.startdate = Date.today
    season.enddate = Date.today+5
    # validate with name
    assert season.valid?
  end

  def test_uniqueness_of_name
    # create with reused name
    season = Season.new :name => 'summer', :startdate => Date.today, :enddate => Date.today+5
    assert !season.valid?
    assert season.errors.invalid?(:name)
    # change the name
    season.name = 'anothername'
    assert season.valid?
  end
end
