require 'test_helper'

class Setup::BlackoutControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:setup_blackout)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create blackout" do
    assert_difference('Setup::Blackout.count') do
      post :create, :blackout => { }
    end

    assert_redirected_to blackout_path(assigns(:blackout))
  end

  test "should show blackout" do
    get :show, :id => setup_blackout(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => setup_blackout(:one).to_param
    assert_response :success
  end

  test "should update blackout" do
    put :update, :id => setup_blackout(:one).to_param, :blackout => { }
    assert_redirected_to blackout_path(assigns(:blackout))
  end

  test "should destroy blackout" do
    assert_difference('Setup::Blackout.count', -1) do
      delete :destroy, :id => setup_blackout(:one).to_param
    end

    assert_redirected_to setup_blackout_path
  end
end
