require 'test_helper'
require File.dirname(__FILE__) + '/../../app/models/discount'
require File.dirname(__FILE__) + '/../../app/models/price'
require File.dirname(__FILE__) + '/../../app/models/taxrate'

class ChargeTest < ActiveSupport::TestCase

 # test + adding two charge objects
  def test_1
    charge1 = Charge.new(:reservation_id => 10,
			 :rate => 10.00,
			 :period => 2,
			 :start_date => Date.today,
			 :end_date => Date.today + 2.days,
			 :amount => 20.00,
			 :discount => 0.00,
			 :charge_units => 1)
    charge2 = Charge.new(:reservation_id => 10,
			 :rate => 10.00,
			 :period => 2,
			 :start_date => Date.today + 2.days,
			 :end_date => Date.today + 4.days,
			 :amount => 20.00,
			 :discount => 0.00,
			 :charge_units => 1)
    charge3 = charge1 + charge2
    assert_equal 40.00, charge3.amount
    assert_equal charge1.start_date, charge3.start_date
    assert_equal charge2.end_date, charge3.end_date
  end

  def test_2
    # all values are arbitrary 
    charge1 = Charge.new(:reservation_id => 10,
			 :season_id => 3,
			 :rate => 10.00,
			 :period => 2,
			 :start_date => Date.today,
			 :end_date => Date.today + 2.days,
			 :amount => 20.00,
			 :discount => 0.00,
			 :charge_units => 1)
    charge2 = Charge.new(:reservation_id => 20,
			 :season_id => 2,
			 :rate => 20.00,
			 :period => 2,
			 :start_date => Date.today + 3.days,
			 :end_date => Date.today + 4.days,
			 :amount => 20.00,
			 :discount => 0.00,
			 :charge_units => 2)
    assert_raise(RuntimeError, 'different_units')  { charge3 = charge1 + charge2 }
    charge2.charge_units = 1
    assert_raise(RuntimeError, 'different_rate')  { charge3 = charge1 + charge2 }
    charge2.rate = 10.00
    assert_raise(RuntimeError, 'different_season')  { charge3 = charge1 + charge2 }
    charge2.season_id = 3
    assert_raise(RuntimeError, 'different_reservation')  { charge3 = charge1 + charge2 }
    charge2.reservation_id = 10
    assert_raise(RuntimeError, 'not_sequential')  { charge3 = charge1 + charge2 }
    charge2.start_date = Date.today + 2.days
    assert_nothing_raised() { charge3 = charge1 + charge2 }
    assert_nothing_raised() { charge3 = charge2 + charge1 }
  end

  # test combine which is +=
  def test_3
    charge1 = Charge.new(:reservation_id => 10,
			 :season_id => 3,
			 :rate => 10.00,
			 :period => 2,
			 :start_date => Date.today,
			 :end_date => Date.today + 2.days,
			 :amount => 20.00,
			 :discount => 0.00,
			 :charge_units => 1)
    charge2 = Charge.new(:reservation_id => 20,
			 :season_id => 2,
			 :rate => 20.00,
			 :period => 2,
			 :start_date => Date.today + 3.days,
			 :end_date => Date.today + 4.days,
			 :amount => 20.00,
			 :discount => 0.00,
			 :charge_units => 2)
    charge1.methods.sort
    assert_raise(RuntimeError, 'different_units')  { charge1.combine charge2 }
    charge2.charge_units = 1
    assert_raise(RuntimeError, 'different_rate')  { charge1.combine charge2 }
    charge2.rate = 10.00
    assert_raise(RuntimeError, 'different_season')  { charge1.combine charge2 }
    charge2.season_id = 3
    assert_raise(RuntimeError, 'different_reservation')  { charge1.combine charge2 }
    charge2.reservation_id = 10
    assert_raise(RuntimeError, 'not_sequential')  { charge1.combine charge2 }
    charge2.start_date = Date.today + 2.days
    assert_nothing_raised() { charge1 += charge2 }
  end

end
