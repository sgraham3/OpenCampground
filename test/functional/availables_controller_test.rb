require 'test_helper'

class AvailablesControllerTest < ActionController::TestCase

  test "should update available" do
    put :update, :id => availables(:one).to_param, :available => { }
    assert_redirected_to available_path(assigns(:available))
  end

end
