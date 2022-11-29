require 'test_helper'

class CardTransactionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:card_transactions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create card_transaction" do
    assert_difference('CardTransaction.count') do
      post :create, :card_transaction => { }
    end

    assert_redirected_to card_transaction_path(assigns(:card_transaction))
  end

  test "should show card_transaction" do
    get :show, :id => card_transactions(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => card_transactions(:one).to_param
    assert_response :success
  end

  test "should update card_transaction" do
    put :update, :id => card_transactions(:one).to_param, :card_transaction => { }
    assert_redirected_to card_transaction_path(assigns(:card_transaction))
  end

  test "should destroy card_transaction" do
    assert_difference('CardTransaction.count', -1) do
      delete :destroy, :id => card_transactions(:one).to_param
    end

    assert_redirected_to card_transactions_path
  end
end
