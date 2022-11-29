require 'test_helper'

class Setup::MailAttachmentsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:setup_mail_attachments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mail_attachment" do
    assert_difference('Setup::MailAttachment.count') do
      post :create, :mail_attachment => { }
    end

    assert_redirected_to mail_attachment_path(assigns(:mail_attachment))
  end

  test "should show mail_attachment" do
    get :show, :id => setup_mail_attachments(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => setup_mail_attachments(:one).to_param
    assert_response :success
  end

  test "should update mail_attachment" do
    put :update, :id => setup_mail_attachments(:one).to_param, :mail_attachment => { }
    assert_redirected_to mail_attachment_path(assigns(:mail_attachment))
  end

  test "should destroy mail_attachment" do
    assert_difference('Setup::MailAttachment.count', -1) do
      delete :destroy, :id => setup_mail_attachments(:one).to_param
    end

    assert_redirected_to setup_mail_attachments_path
  end
end
