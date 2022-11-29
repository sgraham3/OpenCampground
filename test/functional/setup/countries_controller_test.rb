require 'test_helper'

class Setup::CountriesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:setup_countries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create country" do
    assert_difference('Setup::Country.count') do
      post :create, :country => { }
    end

    assert_redirected_to country_path(assigns(:country))
  end

  test "should show country" do
    get :show, :id => setup_countries(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => setup_countries(:one).id
    assert_response :success
  end

  test "should update country" do
    put :update, :id => setup_countries(:one).id, :country => { }
    assert_redirected_to country_path(assigns(:country))
  end

  test "should destroy country" do
    assert_difference('Setup::Country.count', -1) do
      delete :destroy, :id => setup_countries(:one).id
    end

    assert_redirected_to setup_countries_path
  end
end
