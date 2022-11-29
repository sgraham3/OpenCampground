class LoginController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login, :except => [:login]
  before_filter :clear_session

  def login
    debug 'in login#login'
    if request.post?
      user = User.authenticate(params[:name], params[:password])
      if user
        session[:user_id] = user.id
	User.current = user.id
	if params[:remember_me] == "1"
	  token = user.remember_me
	  cookies[:auth_token] =  { :value => token , :expires => 20.years.from_now.utc }
	  debug "login auth_token is " + cookies[:auth_token].inspect
	end
	session[:remote] = nil
	redirect_to(:controller => 'reservation', :action => 'list') 
      else
	flash.now[:notice] = I18n.t('login.Flash.BadPass')
      end
    end
  end

  def logout
    debug 'in login#logout'
    debug "logout auth_token is " + cookies[:auth_token].inspect
    @user_login.forget_me(cookies[:auth_token]) if session[:user_id]
    reset_session
    info "reset session"
    info "session[:top] = #{session[:top]}"
  ensure
    redirect_to :action => 'login'
  end

  def index
  end

end
