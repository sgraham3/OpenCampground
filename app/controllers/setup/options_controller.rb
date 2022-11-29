class Setup::OptionsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize
  in_place_edit_for :option, :home

############################################
# There should only be one record in the 
# each table so these methods will enforce
# that
############################################
  # edit_setup_option GET
  def edit
    @page_title = 'Edit System Options'
    @integration = Integration.first_or_create
    if @option.use_remote_reservations? and !@option.use_login?
      flash[:warning] = "You have enabled remote reservations and do not have logins enabled<br />This can enable a person doing a remote reservation to access your system<br />You should correct this situation or all of your camper records will be exposed!"
    end
  rescue => err
    error err.to_s
    flash[:error] = "Application error"
    redirect_to setup_option_path
  end

  # setup_option PUT
  def update
    # preserve some settings
    seasonal_before = @option.use_seasonal?
    ssl_before = @option.use_ssl?

    case params[:gateway]
    when 'require_gateway'
      opt = {:require_gateway => true, :allow_gateway => false}
    when 'allow_gateway'
      opt = {:require_gateway => false, :allow_gateway => true}
    else
      opt = {:require_gateway => false, :allow_gateway => false}
    end

    if @option.update_attributes(params[:option].merge(opt))
      flash[:notice] = 'Options were successfully updated.'
      # logger.info "Options were successfully updated. seasonal_before is #{seasonal_before} after is #{params[:option][:use_seasonal]}"
      session[:locale] = params[:option][:locale]
      # if previously seasonal reservations were used and we now have
      # turned them off we will recalculate charges for
      # all of the reservations that were seasonal
      if seasonal_before && !@option.use_seasonal?
	Reservation.find_all_by_seasonal(true).each {|r| r.update_attribute :seasonal, false}
	Charge.find_all_by_charge_units(Charge::SEASON).each do |c|
	  begin
	    @reservation = Reservation.find c.reservation_id
	  rescue => err
	    logger.info "reservation #{c.reservation_id} not found"
	    c.destroy
	    next
	  end
	  Charges.new( @reservation.startdate,
		       @reservation.enddate,
		       @reservation.space.price.id,
		       @reservation.discount.id,
		       @reservation.id,
		       @reservation.seasonal)
	end # Charge.find
      end # if before
      if ssl_before.to_s != params[:use_ssl]
        restart(false)
      end
      redirect_to setup_index_path
    else
      @integration = Integration.first_or_create
      render :action => 'edit'
    end
  rescue => err
    error err
    flash[:error] = "Application error"
    redirect_to edit_setup_option_path
  end

end
