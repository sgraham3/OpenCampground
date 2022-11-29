require File.dirname(__FILE__) + '/../../test_helper'
require 'setup/option_controller'

# Re-raise errors caught by the controller.
class Setup::OptionController; def rescue_action(e) raise e end; end

class Setup::OptionControllerTest < Test::Unit::TestCase
  def setup
    @controller = Setup::OptionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
