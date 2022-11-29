require File.dirname(__FILE__) + '/../../test_helper'
require 'setup/discount_controller'

# Re-raise errors caught by the controller.
class Setup::DiscountController; def rescue_action(e) raise e end; end

class Setup::DiscountControllerTest < Test::Unit::TestCase
  def setup
    @controller = Setup::DiscountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
