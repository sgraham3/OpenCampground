class Setup::SecuritiesController < ApplicationController
  require 'digest'
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize
  def show
    @page_title = 'Security Variables Configuration'
  end

  def update
    cookie_token = Digest::SHA2.hexdigest Time.now.usec.to_s
    sleep 1.0
    session_token = Digest::SHA2.hexdigest Time.now.usec.to_s
    @option.update_attributes :cookie_token => cookie_token, :session_token => session_token
    redirect_to setup_security_path
  end

end
