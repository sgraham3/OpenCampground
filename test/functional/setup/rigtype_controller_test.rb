require File.dirname(__FILE__) + '/../../test_helper'
require 'setup/rigtype_controller'

# Re-raise errors caught by the controller.
class Setup::RigtypeController; def rescue_action(e) raise e end; end

class Setup::RigtypeControllerTest < Test::Unit::TestCase
  def setup
    @controller = Setup::RigtypeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
