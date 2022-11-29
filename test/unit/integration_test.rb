require 'test_helper'

class IntegrationTest < ActiveSupport::TestCase
  def test_strip
    int = Integration.create  :cc_merchant_id => ' 12345 ',
			      :cc_api_username => ' testuser ',
			      :cc_api_password => '  kaj;flkjurendf '
    assert int.cc_merchant_id == '12345'
    assert int.cc_api_username == 'testuser'
    assert int.cc_api_password == 'kaj;flkjurendf'
  end
end
