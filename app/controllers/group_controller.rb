class GroupController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  in_place_edit_for :group,  :name
  in_place_edit_for :camper, :first_name
  in_place_edit_for :camper, :address
  in_place_edit_for :camper, :address2
  in_place_edit_for :camper, :city
  in_place_edit_for :camper, :state
  in_place_edit_for :camper, :mail_code
  in_place_edit_for :camper, :email
  in_place_edit_for :camper, :phone

  #
  # the only route into create is from group_reservation -> new_group
  def create
    session[:page_title] = I18n.t('titles.SelCreateWagonmaster')
    @group = Group.new(params[:group])
    res = Reservation.find session[:reservation_id]
    @group.startdate = res.startdate
    @group.enddate = res.enddate
    if @group.save
      flash[:notice] = I18n.t('group.Flash.Created', :name => @group.name)
    else
      flash[:error] = I18n.t('group.Flash.CreateFail', :name => @group.name)
      @page_title = I18n.t('titles.SelCreateGroup')
      @reservation = Reservation.find session[:reservation_id]
      @groups = Group.all
      @use_navigation = false
      render :action => 'new' and return
    end
    session[:group_id] = @group.id
    session[:canx_action] = nil
    redirect_to :controller => 'camper', :action => 'find', :reservation_id => session[:reservation_id].to_i
  end

  def new
    @page_title = I18n.t('titles.SelCreateGroup')
    @reservation = Reservation.find session[:reservation_id]
    @groups = Group.all
    session[:current_action] = 'find'
    session[:current_controller] = 'group'
    session[:canx_action] = nil
    @use_navigation = false
  end

  def found
    session[:page_title] = I18n.t('titles.SelCreateWagonmaster')
    @group = Group.find(params[:id])
    session[:group_id] = @group.id
    flash[:notice] = I18n.t('group.Flash.Selected', :name => @group.name)
    redirect_to :controller => 'camper', :action => 'find', :reservation_id => session[:reservation_id].to_i
  end

  def index
    @page_title = I18n.t('titles.ReturningGroups')
    session[:reservation_id] = nil
    if params[:all] == 'true'
      @group = Group.all :include => ["camper"]
      @showall = true
    else
      @group = Group.all :include => ["camper"], :conditions => ["enddate > ? and expected_number > 0", Date.today]
      @showall = false
    end
    debug "selected #{@group.size} groups"
    session[:current_action] = 'index'
  end

  def show
    if params[:campers]
      ####################################################
      # List all campers for a group
      ####################################################
      campers = []
      group = Group.find params[:id]
      # res_array = Reservation.all(:select => :id, :conditions => ["group_id = ?", group.id])
      res_array = Reservation.find_all_by_group_id(group.id, :select => :camper_id)
      res_array.each {|r| campers << r.camper_id} 
      @campers = Camper.find campers
      if params[:csv] && params[:csv] == 'true'
	debug 'generating csv headers'
	# generate and download a csv file
	# Headers first
	csv_string = I18n.t('camper.Name') + ';'+  I18n.t('camper.Address') + ';'
	csv_string << ';' if @option.use_2nd_address?
	csv_string << I18n.t('camper.City') + ';' + I18n.t('camper.State') + ';' + I18n.t('camper.Zip') + ';'
	csv_string << I18n.t('camper.Country') + ';' if @option.use_country?
	case @option.no_phones
	  when 1
	    csv_string << I18n.t('camper.Phone') + ';'
	  when 2
	    csv_string << I18n.t('camper.Phone2') + ';'
	end
	csv_string << I18n.t('camper.Email') + ';' + I18n.t('camper.LastActivity') + "\n"

	debug 'generating csv data'
	# Data for each
	@campers.each do |c|
	  csv_string << c.full_name + ';' + c.address + ';'
	  csv_string << (c.address2 ? c.address2 : '') + ';' if @option.use_2nd_address?
	  csv_string << c.city + ';' + c.state + ';' + c.mail_code + ';'
	  if @option.use_country?
	    if c.country_id?
	      csv_string << (c.country.name? ? c.country.name : '') + ';'
	    else
	      csv_string << ';'
	    end
	  end
	  csv_string << (c.phone ? c.phone : '' ) + ';' if @option.no_phones > 0
	  csv_string << (c.phone_2 ? c.phone_2 : '' ) + ';' if @option.no_phones > 1
	csv_string << (c.email ? c.email : '' ) + ';' + c.activity.to_s + "\n"
	end
	send_data(csv_string,
		  :type => 'text/csv;charset=iso-8859-1;header=present',
		  :disposition => "attachment; filename=#{group.name}.csv")
      else
        render 'show_campers_in_group'
      end
    elsif params[:reservations]
      ####################################################
      # List all reservations in a group
      # Sort by the start date and space of the reservation
      ####################################################
      group = Group.find params[:id].to_i
      @reservations = Reservation.all( :conditions => ["group_id = ? and archived = ? ", group.id, false], :order => "startdate ASC")
      size = @reservations.size
      group.update_attributes :expected_number => size
      @page_title = size.to_s + ' ' + I18n.t('titles.ResName', :name => group.name)
      render 'show_reservations_in_group'
    else
      begin
        @group = Group.find params[:group_id]
      rescue
	@group = Group.find params[:id]
      end
      @camper = @group.camper
      @page_title = I18n.t('titles.GroupName', :name => ': ' + @group.name)
    end
  end


  def destroy
    group = Group.find(params[:id])
    group.destroy
    if group.errors.count.zero?
      flash[:notice] = I18n.t('group.Flash.Deleted', :name => group.name)
    else
      debug group.errors.full_messages[0]
      (msg,comma,junk) = group.errors.full_messages[0].rpartition ','
      flash[:error] = msg + I18n.t('group.Flash.DeleteFailed', :name => group.name)
    end
    redirect_to group_index_path
  # rescue StaleObjectError => err
    # locking_error(group)
    # error err.to_s
    # redirect_to group_index_path
  end

  private
  def locking_error(cmpr)
    ####################################################
    # Handle an error with record locking
    ####################################################
    flash[:error] = I18n.t('group.Flash.UpdateErr')
  end

end
