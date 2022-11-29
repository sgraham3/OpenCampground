require 'test_helper'

class OptionTest < ActiveSupport::TestCase
  fixtures :options

  def setup
    @option = Option.first
  end

  def test_required
    # initial state should all be false
    req = %w( require_first require_addr require_city require_state require_mailcode require_country require_id require_phone require_email)
    req.each do |r|
      # test the remote require
      assert_equal false, @option.send(r)
      @option.send('update_attribute', r.to_sym, true)
      assert @option.send(r)
      # test the local require
      assert_equal false, @option.send('l_' + r)
      @option.send('update_attribute', ('l_' + r).to_sym, true)
      assert @option.send('l_' + r)
    end
  end
end
