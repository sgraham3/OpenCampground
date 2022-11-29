class Setup::RemotesController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

  # GET /setup_remotes/1/edit
  def edit
    @page_title = 'Setup Remote Options'
  end

  # PUT /setup_remotes/1
  # PUT /setup_remotes/1.xml
  def update
    debug
    if params[:deposit]
      @option.update_attributes :deposit_type => params[:deposit]
      render :update do |page|
	page.replace_html('deposit', :partial => 'deposit')
      end
      return
    elsif params[:option]
      debug 'option'
      if @option.update_attributes(params[:option])
        case @option.deposit_type
	when Remote::Full_charge
	when Remote::Percentage
	  flash[:warning]="Deposit percentage very low" if @option.deposit < 1.0
	  flash[:warning]="Deposit percentage too high" if @option.deposit > 100.0
	when Remote::Fixed_amount
	  flash[:warning]="Deposit amount very low" if @option.deposit < 1.0
	when Remote::Days
	  if defined? params[:count] 
	    flash[:error]="Days value is 0!" if params[:count].to_i < 1
	    flash[:warning]="Days value is greater than 7" if params[:count].to_i > 7
	    @option.update_attributes(:deposit => params[:count].to_f)
	  end
	end
	flash[:notice] = 'Update successful'
	debug 'update successful'
      else
	flash[:error] = 'Options Update failed: ' + @option.errors.full_messages[0]
	error 'Options Update failed' + @option.errors.full_messages[0]
      end
      redirect_to edit_setup_remote_url
    end
  rescue => err
    error err
    redirect_to edit_setup_remote_url
  end

end
