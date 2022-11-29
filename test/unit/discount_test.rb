require 'test_helper'

class DiscountTest < ActiveSupport::TestCase
  fixtures :discounts

  # def test_uniqueness_of_name
    # disc0 = Discount.create :name => 'validname', :amount => 1.0
    # # create with reused name
    # disc = Discount.new :name => 'validname', :amount => 1.0
    # assert disc0.valid?
    # assert !disc.valid?
    # assert disc.errors.invalid?(:name)
    # # change the name
    # disc.name = 'anothername'
    # assert disc.valid?
  # end

  def test_presense_of_name
    # create without name
    disc = Discount.new :amount => 1.0
    assert !disc.valid?
    assert disc.errors.invalid?(:name)
    # put on name
    disc.name = "anything"
    # validate with name
    assert disc.valid?
  end

  def test_range
    disc = Discount.new :name => 'test', :discount_percent => 8.00
    assert disc.valid?
    disc.discount_percent = -0.01
    assert !disc.valid? # no negative discount
    disc.discount_percent = 100.01
    assert !disc.valid? # no more than 100% discount
    disc.discount_percent = 100.00
    assert disc.valid?
    disc.amount = 100.00
    assert !disc.valid? # cannot have both percent and amount
    disc.discount_percent = 0.00
    assert disc.valid?
  end

  def test_charges_percent
    Discount.create :name => 'test', :discount_percent => 8.00, :disc_appl_daily => true, :amount => 0.0
    disc = Discount.find_by_name 'test'
    assert_equal 8.00, disc.charge(100.0, Charge::DAY, Date.new, 1) # 8% discount 
    disc.update_attribute :disc_appl_daily, false
    assert_equal 0.00, disc.charge(100.0, Charge::DAY, Date.new, 1) # disc does not apply to any so 0.0
    disc.update_attribute :disc_appl_week, true
    assert_equal 8.00, disc.charge(100.0, Charge::WEEK, Date.new, 1) 
    assert_equal 8.00, disc.charge(100.0, Charge::WEEK, Date.new, 2) # same results no matter how many weeks
  end

  def test_charges_duration
    Discount.create :name => 'test', :discount_percent => 8.00, :duration => 2 # 2 day duration
    disc = Discount.find_by_name 'test'
    assert_equal 8.00, disc.charge(100.0, Charge::DAY, Date.new, 1) # 8% discount 
    assert_equal 8.00, disc.charge(200.0, Charge::DAY, Date.new, 2) # 8% discount only one day
    assert_equal 0.00, disc.charge(300.0, Charge::DAY, Date.new, 3) # 8% discount all days consumed
  end

  def test_charges_duration2
    Discount.create :name => 'test', :discount_percent => 8.00, :duration => 2 # 2 day duration
    disc = Discount.find_by_name 'test'
    assert_equal 16.00, disc.charge(300.0, Charge::DAY, Date.new, 3) # 8% discount 
  end

  def test_charges_amount
    disc = Discount.new :name => 'test', :amount => 1.23
    assert_equal  1.23, disc.charge(100.0, Charge::DAY, Date.new, 2) # default ONCE 
    assert_equal 1.23, disc.charge(100.0, Charge::WEEK, Date.new, 2) # default ONCE
    assert_equal 1.23, disc.charge(100.0, Charge::MONTH, Date.new, 2) # default ONCE
  end

  def test_charges_periods
    Discount.create :name => 'test', :amount_daily => 1.23, :disc_appl_daily => true
    disc = Discount.find_by_name 'test'
    assert_equal 2.46, disc.charge(100.0, Charge::DAY, Date.new, 2) # per day * 2 days
    assert_equal 0.00, disc.charge(100.0, Charge::WEEK, Date.new, 2) # per day * 2 weeks == 0
    assert_equal 0.00, disc.charge(100.0, Charge::MONTH, Date.new, 2) # per day * 2 months == 0
    disc.update_attributes :amount_weekly => 2.34, :disc_appl_week => true
    assert_equal 2.46, disc.charge(100.0, Charge::DAY, Date.new, 2) # per week * 2 days == 0
    assert_equal 4.68, disc.charge(100.0, Charge::WEEK, Date.new, 2) # per week * 2 weeks == 2.46
    assert_equal 0.00, disc.charge(100.0, Charge::MONTH, Date.new, 2) # per week * 2 months == 0
    disc.update_attributes :amount_monthly => 3.45, :disc_appl_month => true
    assert_equal 2.46, disc.charge(100.0, Charge::DAY, Date.new, 2) # per month * 2 days == 0
    assert_equal 4.68, disc.charge(100.0, Charge::WEEK, Date.new, 2) # per month * 2 weeks == 0
    assert_equal 6.90, disc.charge(100.0, Charge::MONTH, Date.new, 2) # per month * 2 months == 0
  end

end
