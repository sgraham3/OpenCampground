require 'test_helper'

class RateTest < ActiveSupport::TestCase
  fixtures :rates
  fixtures :seasons

  def test_find_current_season
    rates = Rate.find_current 1
    assert_equal 14, rates.size
  end

  def test_find_current_rate
    rate = Rate.find_current_rate 1, 1
    assert_equal rate.price_id, 1
    assert_equal rate.season_id, 1
  end

  def test_no_rate
    Option.first.update_attribute(:variable_rates, false)
    rate = Rate.find_current_rate 1, 1
    assert !rate.no_rate?(5)
    assert !rate.no_rate?(10)
    rate.update_attribute :daily_rate, 0.0
    assert rate.no_rate?(5)
    Option.first.update_attribute(:variable_rates, true)
    rate.update_attribute :monday, 0.0
    assert rate.no_rate?(5)
    assert !rate.no_rate?(10)
    rate.update_attribute :monday, 5.0
    assert !rate.no_rate?(5)
  end
end
