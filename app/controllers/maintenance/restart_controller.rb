class Maintenance::RestartController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  def index
    restart(false)
    redirect_to root_url
  end

end
