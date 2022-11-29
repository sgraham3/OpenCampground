require File.dirname(__FILE__) + '/../test_helper'
require 'archive_controller'

# Re-raise errors caught by the controller.
class ArchiveController; def rescue_action(e) raise e end; end

class ArchiveControllerTest < Test::Unit::TestCase
  # fixtures :archives

  def setup
    @controller = ArchiveController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = archives(:first).id
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:archives)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:archive)
    assert assigns(:archive).valid?
  end

  def test_destroy
    assert_nothing_raised {
      Archive.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Archive.find(@first_id)
    }
  end
end
