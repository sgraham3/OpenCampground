require File.dirname(__FILE__) + '/../../test_helper'
require 'setup/taxrate_controller'

# Re-raise errors caught by the controller.
class Setup::TaxrateController; def rescue_action(e) raise e end; end

class Setup::TaxrateControllerTest < Test::Unit::TestCase
  def setup
    @controller = Setup::TaxrateController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
