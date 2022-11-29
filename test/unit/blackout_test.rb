require 'test_helper'

class BlackoutTest < ActiveSupport::TestCase

  def setup
    Blackout.create :startdate => Date.current + 1, 
		    :enddate => Date.current + 5,
		    :name => 't1'
    Blackout.create :startdate => Date.current + 20, 
		    :enddate => Date.current + 22,
		    :name => 't2'
  end

  def test_valid
    sd = Date.current + 6
    ed = Date.current + 8
    assert sd == Blackout.available(sd, ed)
  end

  def test_invalid
    # start in blacked out
    sd = Date.current + 2
    ed = Date.current + 8
    assert sd != Blackout.available(sd, ed)
    # spanning
    sd = Date.current
    ed = Date.current + 8
    assert sd != Blackout.available(sd, ed)
    # end in
    sd = Date.current + 10
    ed = Date.current + 21
    assert sd != Blackout.available(sd, ed)
  end

  def test_active
    bl = Blackout.find_by_name('t1')
    bl.update_attribute :active, false
    # start in blacked out
    sd = Date.current + 2
    ed = Date.current + 8
    assert sd == Blackout.available(sd, ed)
  end

  def test_edge_cases
    # end date on start of blackout
    sd = Date.current - 2
    ed = Date.current + 1
    assert sd == Blackout.available(sd, ed)
    # end date on start+1 of blackout
    sd = Date.current - 2
    ed = Date.current + 2
    assert sd != Blackout.available(sd, ed)
    # start date on end of blackout
    sd = Date.current + 6
    ed = Date.current + 10
    assert sd == Blackout.available(sd, ed)
    # start date on end+1 of blackout
    sd = Date.current + 6
    ed = Date.current + 10
    assert sd == Blackout.available(sd, ed)
  end

end
