require File.dirname(__FILE__) + '/../../test_helper'
require 'setup/extra_controller'

# Re-raise errors caught by the controller.
class Setup::ExtraController; def rescue_action(e) raise e end; end

class Setup::ExtraControllerTest < Test::Unit::TestCase
  def setup
    @controller = Setup::ExtraController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
