require 'test_helper'

class Report::CardTransactionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:report_card_transactions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create card_transaction" do
    assert_difference('Report::CardTransaction.count') do
      post :create, :card_transaction => { }
    end

    assert_redirected_to card_transaction_path(assigns(:card_transaction))
  end

  test "should show card_transaction" do
    get :show, :id => report_card_transactions(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => report_card_transactions(:one).to_param
    assert_response :success
  end

  test "should update card_transaction" do
    put :update, :id => report_card_transactions(:one).to_param, :card_transaction => { }
    assert_redirected_to card_transaction_path(assigns(:card_transaction))
  end

  test "should destroy card_transaction" do
    assert_difference('Report::CardTransaction.count', -1) do
      delete :destroy, :id => report_card_transactions(:one).to_param
    end

    assert_redirected_to report_card_transactions_path
  end
end
