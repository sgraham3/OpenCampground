require File.dirname(__FILE__) + '/../../test_helper'
require 'setup/tax_controller'

# Re-raise errors caught by the controller.
class Setup::TaxController; def rescue_action(e) raise e end; end

class Setup::TaxControllerTest < Test::Unit::TestCase
  def setup
    @controller = Setup::TaxController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
