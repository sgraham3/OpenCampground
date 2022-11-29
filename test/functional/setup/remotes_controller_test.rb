require 'test_helper'

class Setup::RemotesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:setup_remotes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create remote" do
    assert_difference('Setup::Remote.count') do
      post :create, :remote => { }
    end

    assert_redirected_to remote_path(assigns(:remote))
  end

  test "should show remote" do
    get :show, :id => setup_remotes(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => setup_remotes(:one).to_param
    assert_response :success
  end

  test "should update remote" do
    put :update, :id => setup_remotes(:one).to_param, :remote => { }
    assert_redirected_to remote_path(assigns(:remote))
  end

  test "should destroy remote" do
    assert_difference('Setup::Remote.count', -1) do
      delete :destroy, :id => setup_remotes(:one).to_param
    end

    assert_redirected_to setup_remotes_path
  end
end
