require 'test_helper'

class CampgroundTest < ActiveSupport::TestCase
  # fixtures :options

  # Replace this with your real tests.
  def setup
  end

  def test_opened_and_closed
    opt = Option.first

    # closed for summer
    # the campground is closed from may 1 to oct 1
    opt.update_attributes :closed_start => Date.new(2013,5,1), :closed_end => Date.new(2013,10,1), :use_closed => false

    start_date = Date.new(2013,5,1) ; end_date = Date.new(2013,5,10)
    assert Campground.open?(start_date, end_date) # 0 true use_closed is false

    opt.update_attributes :use_closed => true # use_closed is true

    start_date = Date.new(2013,3,1) ; end_date = Date.new(2013,3,10)
    assert Campground.open?(start_date, end_date) # 1 open - start and end before closed period

    start_date = Date.new(2014,3,31) ; end_date = Date.new(2014,6,1)
    assert Campground.closed?(start_date, end_date) # 2 closed - end date in closed period

    start_date = Date.new(2015,6,1) ; end_date = Date.new(2015,10,10)
    assert Campground.closed?(start_date, end_date) # 3 closed - start date in closed period

    start_date = Date.new(2016,10,2) ; end_date = Date.new(2016,11,1)
    assert Campground.open?(start_date, end_date) # 4 open - start and end after closed period

    start_date = Date.new(2017,4,11) ; end_date = Date.new(2017,10,11)
    assert Campground.closed?(start_date, end_date) # 5 closed - start date before end date after closed period 

    start_date = Date.new(2018,10,1) ; end_date = Date.new(2018,11,1)
    assert Campground.closed?(start_date, end_date) # 6 closed - start date on closed end
    
    start_date = Date.new(2019,3,1) ; end_date = Date.new(2019,5,1)
    assert  Campground.open?(start_date, end_date) # 7 open - end date on closed start

    start_date = Date.new(2020,6,1) ; end_date = Date.new(2020,6,1)
    assert Campground.closed?(start_date, end_date) # 8 closed - end date == start date in closed period

    start_date = Date.new(2021,10,5) ; end_date = Date.new(2021,10,5)
    assert Campground.open?(start_date, end_date) # 9 open - end date == start date not in closed period

    # closed for winter
    # the campground is closed from nov 1 to march 31 of the next year
    opt.update_attributes :closed_start => Date.new(2014,11,1), :closed_end => Date.new(2014,3,31)

    start_date = Date.new(2013,10,1) ; end_date = Date.new(2013,10,10)
    assert Campground.open?(start_date, end_date) # 1 open - start and end before closed period

    start_date = Date.new(2014,10,1) ; end_date = Date.new(2014,12,10)
    assert Campground.closed?(start_date, end_date) # 2 closed - end date in closed period

    start_date = Date.new(2015,3,1) ; end_date = Date.new(2015,4,10)
    assert Campground.closed?(start_date, end_date) # 3 closed - start date in closed period     

    start_date = Date.new(2016,4,1) ; end_date = Date.new(2016,4,10)
    assert Campground.open?(start_date, end_date) # 4 open - start and end after closed period

    start_date = Date.new(2017,10,1) ; end_date = Date.new(2018,4,10)
    assert Campground.closed?(start_date, end_date) # 5 closed - start date before end date after closed period

    start_date = Date.new(2019,3,31) ; end_date = Date.new(2019,4,10)
    assert Campground.closed?(start_date, end_date) # 6 closed - start date on closed end

    start_date = Date.new(2020,9,1) ; end_date = Date.new(2020,10,1)
    assert Campground.open?(start_date, end_date) # 7 open - end date on closed start

    start_date = Date.new(2021,2,1) ; end_date = Date.new(2021,2,1)
    assert Campground.closed?(start_date, end_date) # 8 closed - end date == start date in closed period

    start_date = Date.new(2022,4,5) ; end_date = Date.new(2022,4,5)
    assert Campground.open?(start_date, end_date) # 9 open - end date == start date not in closed period

  end

end
