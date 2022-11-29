require 'test_helper'

class EmailTest < ActiveSupport::TestCase
  fixtures :emails
  
  def test_address
    #####################
    # check for valid addresses
    ####################
    assert Email.address_valid?("abc@def")
    assert Email.address_valid?("abc@def.xyz")
    assert !Email.address_valid?("")
    assert !Email.address_valid?("abc")
    assert !Email.address_valid?("abc&def")
    assert !Email.address_valid?("abc.def")
    assert !Email.address_valid?("abc@")
    assert !Email.address_valid?("@abc")
  end

end
