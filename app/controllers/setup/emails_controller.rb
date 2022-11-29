class Setup::EmailsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

#####################################################
# Email Configuration
#####################################################
  def edit
    @page_title = 'Edit Email configuration'
    @email = Email.first
    unless @email
      @email = Email.new
      @email.save
    end
  end

  def update
    @email = Email.first
    if @email.update_attributes(params[:email])
      flash[:notice] = "Update successful"
      restart(false)
    else
      flash[:error] = "Error in update"
    end
    redirect_to edit_setup_email_url
  end

  def send_test
    email = ResMailer.deliver_tst
    flash[:notice] = "email test successful"
  rescue => error
    flash[:error] = "email test failed: #{error.message}"
  ensure
    redirect_to edit_setup_email_url
  end

end
