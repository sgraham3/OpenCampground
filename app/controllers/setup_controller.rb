class SetupController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

  def index
    @page_title = "Setup"
		@int = Integration.first_or_create
  end
end
