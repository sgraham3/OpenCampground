class AdminController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :clear_session

  def index
    @page_title = "Admin Functions"
  end
end
