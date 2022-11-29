class GroupResController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :check_dates, :only => :find_spaces
  before_filter :cleanup_abandoned, :only => [:new, :change_dates, :change_space]

  def index
    ####################################################
    # we should never get here except by error
    ####################################################
    flash[:warning] = I18n.t('error.Application')
    error "entered from #{session[:controller]} #{session[:action]}"
    redirect_to :action => 'list'
  end

  def new
    ####################################################
    #
    # new reservation.  Just make available all of
    # the fields needed for a reservation
    ####################################################
    @page_title = I18n.t('titles.new_grp_res')
    @seasonal_ok = false
    @reservation = Reservation.new
    @reservation.startdate = currentDate
    @reservation.enddate = @reservation.startdate + 1
    if @option.use_closed?
      unless Campground.open?(@reservation.startdate, @reservation.enddate)
	debug 'not open'
	flash[:warning] = I18n.t('reservation.Flash.ClosedDates', :closed => DateFmt.format_date(@option.closed_start,'long'), :open => DateFmt.format_date(@option.closed_end,'long'))
	@reservation.startdate = Campground.next_open
	@reservation.enddate = @reservation.startdate + 1
      end
    end
    session[:startdate] = @reservation.startdate
    session[:enddate] = @reservation.enddate
    if @option.use_reserve_by_wk?
      session[:count] = 0
      session[:number] = @reservation.startdate.cweek
      session[:year] = @reservation.startdate.cwyear
    end
    session[:reservation_id] = nil
    session[:group_id] = nil
    # we will not save this reservation
    @groups = Group.all
    @count  = Space.available( @reservation.startdate, @reservation.enddate, 0).size if @option.show_available?
    debug "count is #{@count}"
  end
  
  def find_spaces
    ####################################################
    # get all spaces that are available on the dates
    # specified
    ####################################################
    @page_title = I18n.t('titles.GroupResSpaceSel')
    
    # we will keep the available spaces around because it
    # is a lot of work to get them in the first place.  
    # There is a small possibility of multiple assignment
    # of the spaces because a lot of time may elapse before
    # the spaces are commited to the database.  We cannot
    # lock the database because it is simple to abort the
    # task without completing in any way therefore leaving
    # the lock sitting around.  We will try to avoid the
    # problem with warnings in the manual.

    if session[:reservation_id]
      debug "continuing with reservation #{session[:reservation_id]}"
      @reservation = Reservation.find(session[:reservation_id].to_i)
      @sp_array = SpaceAlloc.find_all_by_reservation_id(@reservation.id)
    else
      # first page
      debug "new reservation"
      @reservation = Reservation.new(params[:reservation])
      if @option.use_closed?
	unless Campground.open?(@reservation.startdate, @reservation.enddate)
	  debug 'not open'
	  flash[:warning] = I18n.t('reservation.Flash.ClosedDates', :closed => DateFmt.format_date(@option.closed_start,'long'), :open => DateFmt.format_date(@option.closed_end,'long'))
	  @reservation.startdate = Campground.next_open
	  @reservation.enddate = @reservation.startdate + 1
	end
      end
      @reservation.save!
      @sp_array = []
      session[:reservation_id] =  @reservation.id
    end
    @season = Season.find_by_date(@reservation.startdate)
    spaces = Space.available( @reservation.startdate,
			       @reservation.enddate,
			       @reservation.sitetype_id.to_i )
    @per_page = @option.disp_rows
    @spaces = spaces.paginate :page => params[:page], :per_page => @per_page
    session[:canx_action] = nil
    @use_navigation = false
    @map =  '/map/' + @option.map if @option.map && !@option.map.empty? && @option.use_map?

  end

  def space_selected
    ####################################################
    # save space selected in an array of spaces then
    # change the color of this item in list
    ####################################################
    current_id = params[:space_id].to_i
    # add this space to spaces
    sp = SpaceAlloc.create(:reservation_id => session[:reservation_id], :space_id => current_id)
    # call javascript to change color of row etc.
    space = Space.find(current_id)
    @item = "space-#{space.id}"
    @select = "select-#{space.id}"
    @deselect = "deselect-#{space.id}"
    # change to count_by_reservation_id
    @num_selected = SpaceAlloc.count(:conditions => ["reservation_id = ?",session[:reservation_id]]).to_s
  end

  def space_deselected
    ####################################################
    # remove space deselected from the array of spaces
    # then change the color of this item back to original
    ####################################################
    current_id = params[:space_id].to_i
    # get the array from session if it exists
    sp = SpaceAlloc.delete_all(["reservation_id = ? and space_id = ?", session[:reservation_id], current_id])
    # call javascript to change color of row etc.
    space = Space.find(current_id)
    @item = "space-#{space.id}"
    @select = "select-#{space.id}"
    @deselect = "deselect-#{space.id}"
    @num_selected = SpaceAlloc.count(:conditions => ["reservation_id = ?",session[:reservation_id]]).to_s
  end

  def spaces_selected
    ####################################################
    # spaces have been selected.... now get the rest of 
    # the data for the reservation
    ####################################################

    num_selected = SpaceAlloc.count(:conditions => ["reservation_id = ?",session[:reservation_id]])
    if num_selected == 0
      flash[:warning] = I18n.t('group_res.Flash.NoneSelected')
      debug "redirect to find_spaces"
      redirect_to :action => :find_spaces
    else
      flash[:notice] = I18n.t('group_res.Flash.CntSelected', :count => num_selected)
      session[:next_controller] = 'group_res'
      session[:next_action] = 'create'
      session[:camper_found] = 'create'
      redirect_to new_group_path
    end
  end

  def create
    ####################################################
    # go through the array of spaces selected creating a
    # reservation for each space
    ####################################################
    reservation = Reservation.find(session[:reservation_id].to_i)
    sp_array = SpaceAlloc.find_all_by_reservation_id(session[:reservation_id].to_i)

    # this is called from camper in the case of a new group
    # and the parameters contain a camper id and group_id
    # is in the session.
    #
    # if the user selected an existing group
    # from app/views/group/new.html.erb params will include
    # a group_id and camper_id

    if params[:group_id]
      group = Group.find params[:group_id]
    else
      group = Group.find(session[:group_id].to_i)
    end
    group.camper_id = params[:camper_id].to_i
    group.startdate = reservation.startdate
    group.enddate = reservation.enddate
    group.expected_number = 0
    # some error handling for the group save should be inserted.

    sp_array.each do |sp|
      if Space.confirm_available(0, sp.space_id, reservation.startdate, reservation.enddate).size == 0 
	group.expected_number += 1
	res = Reservation.create(:startdate => reservation.startdate,
				   :enddate => reservation.enddate,
				   :rigtype_id => Rigtype.first,
				   :camper_id => group.camper_id,
				   :group_id => group.id,
				   :special_request => "Group #{group.name}",
				   :discount_id => 1,
				   :space_id => sp.space_id,
				   :sitetype_id => reservation.sitetype_id,
				   :confirm => true)
	Charges.new(res.startdate,
		    res.enddate,
		    res.space.price.id,
		    1,
		    res.id)
	charges = Charge.stay(res.id)
	total = 0.0
	charges.each { |c| total += c.amount - c.discount }
	total += calculate_extras(res.id)
	total -= res.onetime_discount
	tax_amount = Taxrate.calculate_tax(res.id, @option)
	res.total = total
	res.tax_amount = tax_amount
	res.add_log("group reservation made")
	res.save
      else
	space = Space.find(sp.space_id)
	error "Attempted allocation of space #{space.name} allready booked"
        if flash[:error]
	  flash[:error] += " space #{space.name} booked on another reservation"
	else
	  flash[:error] = "space #{space.name} booked on another reservation"
	end
      end
    end
    group.save
    # no longer need the reservation which was really a 
    # standin to accumulate some reservation data
    Reason.close_reason_is "abandoned"
    reservation.destroy
    session[:reservation_id] = nil
    session[:group_id] = nil
    flash[:notice] = I18n.t('group_res.Flash.ResCreated', :count => group.expected_number, :name => group.name)
    # sp_array.delete
    redirect_to :controller => 'reservation', :action => 'list'
  end

  def cancel
    ####################################################
    # cancel a complete group reservation 
    #
    ####################################################
    res = Reservation.find(params[:reservation_id].to_i)
    group = res.group.name
    reservations = Reservation.all(:conditions => ["group_id = ? and archived = ?", res.group_id, false])
    if @option.use_login? && defined? @user_login
      Reason.close_reason_is "cancelled by: #{@user_login.name} at: #{currentTime}"
    else
      Reason.close_reason_is "cancelled at: #{currentTime}"
    end
    flash[:notice] = I18n.t('group_res.Flash.Canx')
    reservations.each do |r|
      # then destroy the reservation
      begin
	r.archive
	flash[:notice] += I18n.t('group_res.Flash.OK', :name => r.space.name)
	r.add_log("group cancel")
      rescue RuntimeError => err
	error err.to_s
	flash[:notice] += I18n.t('group_res.Flash.Fail', :name => r.space.name)
      rescue ActiveRecord::StaleObjectError => err
	error err.to_s
	locking_error(r)
      end
    end
    redirect_to :controller => 'reservation', :action => 'list'
  end
  
  def checkin
    ####################################################
    # do checkin.  Resume on reservation/list
    ####################################################
        
    error = false

    reservations = Reservation.all(:conditions => ["group_id = ? and checked_in = ? and archived = ?", params[:group_id], false, false])
    
    msg = I18n.t('group_res.Flash.Unavailable')
    reservations.each do |r|
      if r.space.unavailable | r.space.occupied
	msg += "#{r.space.name} "
	error = true
      end
    end
    if error == true
      flash[:error] = msg + I18n.t('group_res.Flash.Correct')
      redirect_to  :controller => 'reservation', :action => 'in_park'
    else
      flash[:notice] = I18n.t('group_res.Flash.Checkin')
      reservations.each do |r|
	r.checked_in = true
	r.camper.active
	begin
	  if r.save
	    debug "checking in #{r.space.name}"
	    flash[:notice] += I18n.t('group_res.Flash.OK', :name => r.space.name)
	    r.add_log("group checkin")
	  else
	    flash[:notice] += I18n.t('group_res.Flash.Fail', :name => r.space.name)
	  end
	rescue ActiveRecord::StaleObjectError => err
	  error err.to_s
	  locking_error(r)
	end
      end
      redirect_to  :controller => 'reservation', :action => 'list'
    end
  end

  def checkout
    ####################################################
    # do checkout
    ####################################################
    reservations = Reservation.all(:conditions => ["group_id = ? and checked_in = ? and archived = ?", params[:group_id], true, false])
    flash[:notice] = I18n.t('group_res.Flash.Checkout')
    if @option.use_login? && defined? @user_login
      Reason.close_reason_is "checkout by: #{@user_login.name} at: #{currentTime}"
    else
      Reason.close_reason_is "checkout at: #{currentTime}"
    end
    reservations.each do |r|
      # then destroy the reservation
      # update camper activity
      camper = Camper.update(r.camper_id, :activity => currentDate)
      begin
	r.checkout(@option, @option.use_login? ? @user_login.name : nil)
	debug "checking out #{r.space.name}"
	flash[:notice] += I18n.t('group_res.Flash.OK', :name => r.space.name)
	r.add_log("group checkout")
      rescue RuntimeError => err
	error err.to_s
	flash[:notice] += I18n.t('group_res.Flash.Fail', :name => r.space.name)
      rescue ActiveRecord::StaleObjectError => err
	error err.to_s
	locking_error(r)
      end
    end
    redirect_to  :controller => 'reservation', :action => 'in_park'
  end
  
end
