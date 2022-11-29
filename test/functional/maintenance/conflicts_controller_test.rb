require 'test_helper'

class Maintenance::ConflictsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:maintenance_conflicts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create conflict" do
    assert_difference('Maintenance::Conflict.count') do
      post :create, :conflict => { }
    end

    assert_redirected_to conflict_path(assigns(:conflict))
  end

  test "should show conflict" do
    get :show, :id => maintenance_conflicts(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => maintenance_conflicts(:one).to_param
    assert_response :success
  end

  test "should update conflict" do
    put :update, :id => maintenance_conflicts(:one).to_param, :conflict => { }
    assert_redirected_to conflict_path(assigns(:conflict))
  end

  test "should destroy conflict" do
    assert_difference('Maintenance::Conflict.count', -1) do
      delete :destroy, :id => maintenance_conflicts(:one).to_param
    end

    assert_redirected_to maintenance_conflicts_path
  end
end
