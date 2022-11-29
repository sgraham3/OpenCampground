require 'test_helper'

class Setup::IntegrationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:setup_integrations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create integration" do
    assert_difference('Setup::Integration.count') do
      post :create, :integration => { }
    end

    assert_redirected_to integration_path(assigns(:integration))
  end

  test "should show integration" do
    get :show, :id => setup_integrations(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => setup_integrations(:one).to_param
    assert_response :success
  end

  test "should update integration" do
    put :update, :id => setup_integrations(:one).to_param, :integration => { }
    assert_redirected_to integration_path(assigns(:integration))
  end

  test "should destroy integration" do
    assert_difference('Setup::Integration.count', -1) do
      delete :destroy, :id => setup_integrations(:one).to_param
    end

    assert_redirected_to setup_integrations_path
  end
end
