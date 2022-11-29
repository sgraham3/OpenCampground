require 'test_helper'

class ExtraChargeTest < ActiveSupport::TestCase
  fixtures :extra_charges
  # should add create and delete tests

  #
  # 

  def test_exists
    extra_id = 5
    reservation_id = 10
    
    # this one exists
    assert ExtraCharge.exists?(5, 10)

    # this one does not exist
    assert !ExtraCharge.exists?(6, 10)
  end
  
  def test_number 
    assert_equal 0, ExtraCharge.number(5, 10)
    assert_equal 4, ExtraCharge.number(6, 9)
  end
  
  def test_count 
    assert_equal 1, ExtraCharge.count(5, 10)
    assert_equal 0, ExtraCharge.count(6, 10)
  end
  
  def test_save_charges
    assert true
  end

end
