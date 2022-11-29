require 'test_helper'
require File.dirname(__FILE__) + '/../../app/models/discount'
require File.dirname(__FILE__) + '/../../app/models/price'
require File.dirname(__FILE__) + '/../../app/models/taxrate'

class ChargesTest < ActiveSupport::TestCase
#
#

  #
  # test charges for one day for reservation 20
  # 12.00 per day, 0% discount
  # args for Charges.new are start_dt, end_dt, price_id, discount_id, res_id, full_season

  def test_01
    Charges.new(Date.new(2011,01,01),
                Date.new(2011,01,02),
		1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 20, charges[0].reservation_id
    assert_equal 1, charges[0].season_id
    assert_equal Date.new(2011,01,01), charges[0].start_date
    assert_equal Date.new(2011,01,02), charges[0].end_date
    assert_equal 1.0, charges[0].period.to_f
    assert_equal 12.0, charges[0].rate.to_f
    assert_equal 12.0, charges[0].amount.to_f
    assert_equal 0.0, charges[0].discount.to_f
    assert_equal Charge::DAY, charges[0].charge_units
  end

  # test charges for one day for reservation 20
  # season 'Apr-May'
  # 15.00 per day, 0% discount
  def test_01a
    Charges.new(Date.new(2011,05,01),
                Date.new(2011,05,02),
		1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 2, charges[0].season_id
    assert_equal Date.new(2011,05,01), charges[0].start_date
    assert_equal Date.new(2011,05,02), charges[0].end_date
    assert_equal 1.0, charges[0].period.to_f
    assert_equal 15.0, charges[0].rate.to_f
    assert_equal 15.0, charges[0].amount.to_f
    assert_equal Charge::DAY, charges[0].charge_units
  end

  # test charges for 3 days
  # 12.00 per day, 0% discount
  def test_02
    Charges.new(Date.new(2011,01,01),
                Date.new(2011,01,04),
		1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 1, charges[0].season_id
    assert_equal Date.new(2011,01,01), charges[0].start_date
    assert_equal Date.new(2011,01,04), charges[0].end_date
    assert_equal 3.0, charges[0].period.to_f
    assert_equal 12.0, charges[0].rate.to_f
    assert_equal 36.0, charges[0].amount.to_f
    assert_equal 0.0, charges[0].discount.to_f
    assert_equal Charge::DAY, charges[0].charge_units
  end

  # test charges for 3 days 
  # 12.00 per day, 10% discount
  def test_03
    Charges.new(Date.new(2011,01,01),
                Date.new(2011,01,04),
		1, 2, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 1, charges[0].season_id
    assert_equal 3.0, charges[0].period.to_f
    assert_equal 12.0, charges[0].rate.to_f
    assert_equal 36.0, charges[0].amount.to_f
    assert_equal 3.6, charges[0].discount.to_f
    assert_equal Charge::DAY, charges[0].charge_units
  end

  # test charges for 1 week rate
  # 12.00 per day, 72.00 per week, 00% discount
  def test_04
    Charges.new(Date.new(2011,01,01),
                Date.new(2011,01,8),
		1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 1, charges[0].season_id
    assert_equal Date.new(2011,01,01), charges[0].start_date
    assert_equal Date.new(2011,01,8), charges[0].end_date
    assert_equal 1.0, charges[0].period.to_f
    assert_equal 72.0, charges[0].rate.to_f
    assert_equal 72.0, charges[0].amount.to_f
    assert_equal 0.0, charges[0].discount.to_f
    assert_equal Charge::WEEK, charges[0].charge_units
  end

  # test charges for 1 week rate season 'Apr-May'
  # 15.00 per day, 90.00 per week, 00% discount
  def test_04a
    Charges.new(Date.new(2011,05,01),
                Date.new(2011,05,8),
		1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 2, charges[0].season_id
    assert_equal 1.0, charges[0].period.to_f
    assert_equal 90.0, charges[0].rate.to_f
    assert_equal 90.0, charges[0].amount.to_f
    assert_equal 0.0, charges[0].discount.to_f
    assert_equal Charge::WEEK, charges[0].charge_units
  end

  # test charges for 1 week rate with 10% discount
  # 12.00 per day, 72.00 per week, 10% Good Sam discount
  def test_05
    Charges.new(Date.new(2011,01,01),
                Date.new(2011,01,8),
		1, 3, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 1, charges[0].season_id
    assert_equal 1.0, charges[0].period.to_f
    assert_equal 72.0, charges[0].rate.to_f
    assert_equal 72.0, charges[0].amount.to_f
    assert_equal 7.2, charges[0].discount.to_f
    assert_equal Charge::WEEK, charges[0].charge_units
  end

  # test charges for 1 week with no weekly discount rates
  # 20.00 per day, 0% discount
  def test_06
    Charges.new(Date.new(2011,01,01),
                Date.new(2011,01,8),
		2, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 1, charges[0].season_id
    assert_equal 7.0, charges[0].period.to_f
    assert_equal 20.0, charges[0].rate.to_f
    assert_equal 140.0, charges[0].amount.to_f
    assert_equal 0.0, charges[0].discount.to_f
    assert_equal Charge::DAY, charges[0].charge_units
  end

  # test charges for 10 days
  # 12.00 per day, 72.00 per week, 00% discount
  def test_07
    Charges.new(Date.new(2011,01,01),
                Date.new(2011,01,11),
		1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    2, charges.size
    assert_equal 1, charges[0].season_id
    assert_equal Date.new(2011,01,01), charges[0].start_date
    assert_equal Date.new(2011,01,8), charges[0].end_date
    assert_equal 1.0, charges[0].period.to_f
    assert_equal 72.0, charges[0].rate.to_f
    assert_equal 72.0, charges[0].amount.to_f
    assert_equal 0.0, charges[0].discount.to_f
    assert_equal Charge::WEEK, charges[0].charge_units
    assert_equal 1, charges[1].season_id
    assert_equal Date.new(2011,01,8), charges[1].start_date
    assert_equal Date.new(2011,01,11), charges[1].end_date
    assert_equal 3.0, charges[1].period.to_f
    assert_equal 12.0, charges[1].rate.to_f
    assert_equal 36.0, charges[1].amount.to_f
    assert_equal 0.0, charges[1].discount.to_f
    assert_equal Charge::DAY, charges[1].charge_units
  end

  # test charges for 10 days season 'Apr-May'
  # 15.00 per day, 90.00 per week, 00% discount
  def test_07a
    Charges.new(Date.new(2011,05,01),
                Date.new(2011,05,11),
		1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    2, charges.size
    assert_equal 2, charges[0].season_id
    assert_equal 1.0, charges[0].period.to_f
    assert_equal 90.0, charges[0].rate.to_f
    assert_equal 90.0, charges[0].amount.to_f
    assert_equal Charge::WEEK, charges[0].charge_units
    assert_equal 2, charges[1].season_id
    assert_equal 3.0, charges[1].period.to_f
    assert_equal 15.0, charges[1].rate.to_f
    assert_equal 45.0, charges[1].amount.to_f
    assert_equal Charge::DAY, charges[1].charge_units
  end

  # test charges for 1 month 31 days
  # 12.00 per day, 72.00 per week, 288.00 per month 00% discount
  def test_31day_mo
    Charges.new(Date.new(2011,01,15),
                Date.new(2011,02,15),
		1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 1, charges[0].season_id
    assert_equal Date.new(2011,01,15), charges[0].start_date
    assert_equal Date.new(2011,02,15), charges[0].end_date
    assert_equal 1.0, charges[0].period.to_f
    assert_equal 288.0, charges[0].rate.to_f
    assert_equal 288.0, charges[0].amount.to_f
    assert_equal 0.0, charges[0].discount.to_f
    assert_equal Charge::MONTH, charges[0].charge_units
  end

  # test charges for 1 month 30 days
  # 12.00 per day, 72.00 per week, 288.00 per month 00% discount
  def test_30day_mo
    Charges.new(Date.new(2011,11,15),
                Date.new(2011,12,15),
		1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 1, charges[0].season_id
    assert_equal Date.new(2011,11,15), charges[0].start_date
    assert_equal Date.new(2011,12,15), charges[0].end_date
    assert_equal 1.0, charges[0].period.to_f
    assert_equal 288.0, charges[0].rate.to_f
    assert_equal 288.0, charges[0].amount.to_f
    assert_equal 0.0, charges[0].discount.to_f
    assert_equal Charge::MONTH, charges[0].charge_units
  end

  # test charges for 1 month 30 days + 5 days ending on the end of the month
  # 12.00 per day, 72.00 per week, 288.00 per month 00% discount
  def test_30day_mo_plus
    Charges.new(Date.new(2011,11,26),
                Date.new(2011,12,31),
		1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    2, charges.size
    assert_equal 1, charges[0].season_id
    assert_equal 1, charges[1].season_id
    assert_equal Date.new(2011,11,26), charges[0].start_date
    assert_equal Date.new(2011,12,26), charges[0].end_date
    assert_equal Date.new(2011,12,26), charges[1].start_date
    assert_equal Date.new(2011,12,31), charges[1].end_date
    assert_equal 1.0, charges[0].period.to_f
    assert_equal 288.0, charges[0].rate.to_f
    assert_equal 288.0, charges[0].amount.to_f
    assert_equal 0.0, charges[0].discount.to_f
    assert_equal 5.0, charges[1].period.to_f
    assert_equal 12.0, charges[1].rate.to_f
    assert_equal 60.0, charges[1].amount.to_f
    assert_equal 0.0, charges[1].discount.to_f
    assert_equal Charge::MONTH, charges[0].charge_units
    assert_equal Charge::DAY, charges[1].charge_units
  end

  # test charges for 1 month  28 days
  # 12.00 per day, 72.00 per week, 288.00 per month 00% discount
  def test_28day_mo
    Charges.new(Date.new(2011,02,15),
                Date.new(2011,03,15),
		1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 1, charges[0].season_id
    assert_equal Date.new(2011,02,15), charges[0].start_date
    assert_equal Date.new(2011,03,15), charges[0].end_date
    assert_equal 1.0, charges[0].period.to_f
    assert_equal 288.0, charges[0].rate.to_f
    assert_equal 288.0, charges[0].amount.to_f
    assert_equal 0.0, charges[0].discount.to_f
    assert_equal Charge::MONTH, charges[0].charge_units
  end

  # test charges for 1 month season 'Apr-May'
  # 15.00 per day, 90.00 per week, 360.00 per month 00% discount
  def test_08a
    Charges.new(Date.new(2011,05,01),
                Date.new(2011,06,01),
		1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 2, charges[0].season_id
    assert_equal 1.0, charges[0].period.to_f
    assert_equal 360.0, charges[0].rate.to_f
    assert_equal 360.0, charges[0].amount.to_f
    assert_equal Charge::MONTH, charges[0].charge_units
  end

  # test charges for 1 month season 'July-August' 2012
  # 940.00 per month 100% discount
  def test_08aa
    disc = Discount.create!(:name => 'staff',
                            :discount_percent => 100.0,
			    :disc_appl_month => true )
    Charges.new(Date.new(2012,6,15),
                Date.new(2012,8,15),
		2, disc.id, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    2, charges.size

    ActiveRecord::Base.logger.debug "season is #{charges[0].season_id}"
    assert_equal 8, charges[0].season_id
    assert_equal Charge::MONTH, charges[0].charge_units
    assert_in_delta 0.533, charges[0].period.to_f, 0.005
    assert_equal 500.0, charges[0].rate.to_f
    assert_in_delta 266.666, charges[0].amount.to_f, 0.005
    assert_in_delta 266.666, charges[0].discount.to_f, 0.005

    ActiveRecord::Base.logger.debug "season is #{charges[0].season_id}"
    assert_equal 9, charges[1].season_id
    assert_equal Charge::MONTH, charges[1].charge_units
    assert_in_delta 1.467, charges[1].period.to_f, 0.005
    assert_equal 940.0, charges[1].rate.to_f
    assert_in_delta 1378.67, charges[1].amount.to_f, 0.005
    assert_in_delta 1378.67, charges[1].discount.to_f, 0.005
  end

  ##########################################################
  # test seasons
  ##########################################################

  # test charges for 1 month spanning season 'Apr-May' & 'Jun'
  # 15.00 per day, 90.00 per week, 360.00 per month 'Apr-May'
  # 31.50 per day, 189.00 per week, 756.00 per month 'Jun'
  def test_08b
    Charges.new(Date.new(2011,05,10),
                Date.new(2011,06,10),
		1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    2, charges.size
    assert_equal 2, charges[0].season_id
    assert_in_delta 0.71, charges[0].period.to_f, 0.005
    assert_equal 360.0, charges[0].rate.to_f
    assert_in_delta 255.48, charges[0].amount.to_f, 0.005
    assert_equal Charge::MONTH, charges[0].charge_units
    assert_equal 3, charges[1].season_id
    assert_in_delta 0.29, charges[1].period.to_f, 0.005
    assert_equal 756.0, charges[1].rate.to_f
    assert_in_delta 219.48, charges[1].amount.to_f, 0.005
    assert_equal Charge::MONTH, charges[1].charge_units
  end

  # same basic test but no monthly
  def test_08c
    Rate.find_all_by_price_id(1).each {|r| r.update_attribute :monthly_rate, 0.0}
    Charges.new(Date.new(2011,05,10),
                Date.new(2011,06,10),
		1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    3, charges.size

    assert_equal 2, charges[0].season_id
    assert_in_delta 3.143, charges[0].period.to_f, 0.005
    assert_equal 90.0, charges[0].rate.to_f
    assert_in_delta 282.86, charges[0].amount.to_f, 0.005
    assert_equal Charge::WEEK, charges[0].charge_units

    assert_equal 3, charges[1].season_id
    assert_in_delta 0.857, charges[1].period.to_f, 0.005
    assert_equal 189.0, charges[1].rate.to_f
    assert_in_delta 162.00, charges[1].amount.to_f, 0.005
    assert_equal Charge::WEEK, charges[1].charge_units

    assert_equal 3, charges[2].season_id
    assert_in_delta 3.0, charges[2].period.to_f, 0.005
    assert_equal 31.5, charges[2].rate.to_f
    assert_in_delta 94.5, charges[2].amount.to_f, 0.005
    assert_equal Charge::DAY, charges[2].charge_units
  end

  # same basic test but no monthly or weekly
  def test_08d
    Rate.find_all_by_price_id(1).each {|r| r.update_attribute :monthly_rate, 0.0}
    Rate.find_all_by_price_id(1).each {|r| r.update_attribute :weekly_rate, 0.0}
    Charges.new(Date.new(2011,05,10),
                Date.new(2011,06,10),
		1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    # charges.each {|c| p c.inspect}
    assert_equal    2, charges.size

    assert_equal 2, charges[0].season_id
    assert_in_delta 22.0, charges[0].period.to_f, 0.005
    assert_equal 15.0, charges[0].rate.to_f
    assert_in_delta 330.00, charges[0].amount.to_f, 0.005
    assert_equal Charge::DAY, charges[0].charge_units

    assert_equal 3, charges[1].season_id
    assert_in_delta 9.0, charges[1].period.to_f, 0.005
    assert_equal 31.5, charges[1].rate.to_f
    assert_in_delta 283.5, charges[1].amount.to_f, 0.005
    assert_equal Charge::DAY, charges[1].charge_units
  end

  # test charges for 1 month 10% discount
  # 12.00 per day, 72.00 per week, 288.00 per month 10% FMCA discount
  def test_09
    ActiveRecord::Base.logger.debug "test_09"
    Charges.new(Date.new(2011,01,01),
                Date.new(2011,02,01),
		1, 2, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 1, charges[0].season_id
    assert_equal 1.0, charges[0].period.to_f
    assert_equal 288.0, charges[0].rate.to_f
    assert_equal 288.0, charges[0].amount.to_f
    assert_equal 28.8, charges[0].discount.to_f
    assert_equal Charge::MONTH, charges[0].charge_units
  end

  # test charges for 1 month no monthly rate
  # 22.00 per day no weekly rate 0% discount
  def test_10
    ActiveRecord::Base.logger.debug "test_10"
    Charges.new(Date.new(2011,01,01),
                Date.new(2011,02,01),
		2, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 1, charges[0].season_id
    assert_equal 31.0, charges[0].period.to_f
    assert_equal 20.0, charges[0].rate.to_f
    assert_equal 620.0, charges[0].amount.to_f
    assert_equal 0.0, charges[0].discount.to_f
    assert_equal Charge::DAY, charges[0].charge_units
  end

  # test charges for 1 month no monthly rate with 10% discount
  # 22.00 per day, 132.00 per week 10% discount
  def test_11
    ActiveRecord::Base.logger.debug "test_11"
    Charges.new(Date.new(2011,01,01),
                Date.new(2011,02,01),
		3, 3, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    2, charges.size
    assert_equal 1, charges[0].season_id
    assert_equal 4.0, charges[0].period.to_f
    assert_equal 132.0, charges[0].rate.to_f
    assert_equal 528.0, charges[0].amount.to_f
    assert_equal 52.8, charges[0].discount.to_f
    assert_equal Charge::WEEK, charges[0].charge_units
    assert_equal 3.0, charges[1].period.to_f
    assert_equal 22.0, charges[1].rate.to_f
    assert_equal 66.0, charges[1].amount.to_f
    assert_equal 6.6, charges[1].discount.to_f
    assert_equal Charge::DAY, charges[1].charge_units
  end

  # test charges for 1 month no monthly rate no disc
  # 20.00 per day, 0% discount
  def test_12
    Charges.new(Date.new(2011,01,01),
                Date.new(2011,02,01),
		2, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 1, charges[0].season_id
    assert_equal 31.0, charges[0].period.to_f
    assert_equal 20.0, charges[0].rate.to_f
    assert_equal 20.0*31.0, charges[0].amount.to_f
    assert_equal 0.0, charges[0].discount.to_f
    assert_equal Charge::DAY, charges[0].charge_units
  end

  # test charges for apr 15 to oct 15 spanning 4 seasons
  def test_13
    Charges.new(Date.new(2011,04,15),
                Date.new(2011,10,15),
		4, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    4, charges.size
    assert_equal 2, charges[0].season_id
    assert_in_delta 1.53, charges[0].period.to_f, 0.005
    assert_equal 370.0, charges[0].rate.to_f
    assert_in_delta 567.32, charges[0].amount.to_f, 0.01
    assert_equal Charge::MONTH, charges[0].charge_units
    assert_equal 3, charges[1].season_id
    assert_in_delta 1.0, charges[1].period.to_f, 0.005
    assert_equal 500.0, charges[1].rate.to_f
    assert_in_delta 500, charges[1].amount.to_f, 0.005
    assert_equal Charge::MONTH, charges[1].charge_units
    assert_equal 4, charges[2].season_id
    assert_in_delta 2.0, charges[2].period.to_f, 0.005
    assert_equal 785.0, charges[2].rate.to_f
    assert_in_delta 1570.0, charges[2].amount.to_f, 0.005
    assert_equal Charge::MONTH, charges[2].charge_units
    assert_equal 5, charges[3].season_id
    assert_in_delta 1.47, charges[3].period.to_f, 0.005
    assert_equal 410.0, charges[3].rate.to_f
    assert_in_delta 601.33, charges[3].amount.to_f, 0.005
    assert_equal Charge::MONTH, charges[3].charge_units
  end

  # test charges for seasonal
  def test_14
    Charges.new(Date.new(2011,01,01),
                Date.new(2011,01,02),
		1, 1, 20, true)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 1, charges[0].season_id
    assert_in_delta 1, charges[0].period.to_f, 0.005
    assert_equal 2200.0, charges[0].rate.to_f
    assert_in_delta 2200.0, charges[0].amount.to_f, 0.005
    assert_equal Charge::SEASON, charges[0].charge_units
  end

  # test charges for variable rates
  # a variable rate is set up for season 1 price 6
  # the variable rates are set up as 20 for weekdays
  # and 25 for weekends

  # this is for saturday only
  def test_15
    # have to set variable in options
    opt = Option.first
    opt.update_attribute :variable_rates, true
    Charges.new(Date.new(2011,01,01),
                Date.new(2011,01,02),
		6, 1, 20, false)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 20, charges[0].reservation_id
    assert_equal 1, charges[0].season_id
    assert_equal Date.new(2011,01,01), charges[0].start_date
    assert_equal Date.new(2011,01,02), charges[0].end_date
    assert_equal 1.0, charges[0].period.to_f
    assert_equal 25.0, charges[0].rate.to_f
    assert_equal 25.0, charges[0].amount.to_f
    assert_equal 0.0, charges[0].discount.to_f
    assert_equal Charge::DAY, charges[0].charge_units
  end

  # saturday, sunday and monday
  def test_16
    # have to set variable in options
    opt = Option.first
    opt.update_attribute :variable_rates, true
    Charges.new(Date.new(2011,01,01),
                Date.new(2011,01,04),
		6, 1, 20, false)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    2, charges.size
    assert_equal 20, charges[0].reservation_id
    assert_equal 1, charges[0].season_id
    assert_equal Date.new(2011,01,01), charges[0].start_date
    assert_equal Date.new(2011,01,03), charges[0].end_date
    assert_equal 2.0, charges[0].period.to_f
    assert_equal 25.0, charges[0].rate.to_f
    assert_equal 50.0, charges[0].amount.to_f
    assert_equal Charge::DAY, charges[0].charge_units
    assert_equal Date.new(2011,01,03), charges[1].start_date
    assert_equal Date.new(2011,01,04), charges[1].end_date
    assert_equal 1.0, charges[1].period.to_f
    assert_equal 20.0, charges[1].rate.to_f
    assert_equal 20.0, charges[1].amount.to_f
  end

  # test spanning seasons
  # one day in default and one day in apr-may
  # 12.00 per day, 0% discount in default
  # 15.00 per day, 0% discount in apr-may
  def test_17
    ActiveRecord::Base.logger.debug "start season test_17 #{ Season.find_by_date(Date.new(2011,04,14)).name}"
    ActiveRecord::Base.logger.debug "end   season test_17 #{ Season.find_by_date(Date.new(2011,04,16)).name}"
    Charges.new(Date.new(2011,04,14),
                Date.new(2011,04,16),
		1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    2, charges.size
    assert_equal 1, charges[0].season_id
    assert_equal 1.0, charges[0].period.to_f
    assert_equal 12.0, charges[0].rate.to_f
    assert_equal 12.0, charges[0].amount.to_f
    assert_equal Charge::DAY, charges[0].charge_units
    assert_equal 2, charges[1].season_id
    assert_equal 1.0, charges[1].period.to_f
    assert_equal 15.0, charges[1].rate.to_f
    assert_equal 15.0, charges[1].amount.to_f
    assert_equal Charge::DAY, charges[1].charge_units
  end

  # one day in apr-may and one day in june
  def test_18
    start_date = Date.new(2011,05,31)
    end_date = Date.new(2011,06,02)
    ActiveRecord::Base.logger.debug "start season test_18 #{ Season.find_by_date(start_date).id}"
    ActiveRecord::Base.logger.debug "end   season test_18 #{ Season.find_by_date(end_date).id}"
    Charges.new(start_date, end_date, 1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    2, charges.count
    charges.each do |c|
      ActiveRecord::Base.logger.debug "res_id #{c.reservation_id}, start #{c.start_date}, end #{c.end_date}"
    end
    assert_equal 2, charges[0].season_id
    assert_equal 1.0, charges[0].period.to_f
    assert_equal 15.0, charges[0].rate.to_f
    assert_equal 15.0, charges[0].amount.to_f
    assert_equal Charge::DAY, charges[0].charge_units
    assert_equal 3, charges[1].season_id
    assert_equal 1.0, charges[1].period.to_f
    assert_equal 31.5, charges[1].rate.to_f
    assert_equal 31.5, charges[1].amount.to_f
    assert_equal Charge::DAY, charges[1].charge_units
  end

  # define a season of two days and reservation 
  # of 4 days starting before ending after
  def test_19
    Charges.new(Date.new(2011,05,01),
                Date.new(2011,06,01),
		1, 1, 20)
    charges = Charge.find_all_by_reservation_id 20
    assert_equal    1, charges.size
    assert_equal 2, charges[0].season_id
    assert_equal 1.0, charges[0].period.to_f
    assert_equal 360.0, charges[0].rate.to_f
    assert_equal 360.0, charges[0].amount.to_f
    assert_equal Charge::MONTH, charges[0].charge_units
  end



end
