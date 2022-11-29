class Admin::ArchivesController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :clear_session

  def index
    @page_title = 'Archives'
    session[:reservation_id] = nil
    if params[:page]
      session[:a_page] = params[:page]
      page = params[:page]
    elsif session[:a_page]
      page = session[:a_page]
    else 
      page = 1
      session[:a_page] = 1
    end
    @archives = Archive.paginate :order => @option.archive_list_sort, :page => page, :per_page => @option.disp_rows
  rescue
    @option.update_attributes :archive_list_sort => "startdate ASC"
    @archives = Archive.paginate :order => @option.archive_list_sort, :page => params[:page], :per_page => @option.disp_rows
  end

  def show
    session[:reservation_id] = nil
    if params[:name]
      debug "name is #{params[:name]}"
      archives = Archive.by_name(params[:name])
      if archives.size == 0
	flash[:error] = "archive records for #{params[:name]} not found"
	redirect_to admin_archives_url and return
      else
	@page_title = "Archive records for #{params[:name]}"
	@option.update_attributes :archive_list_sort => "startdate ASC"
	@archives = archives.paginate :order => @option.archive_list_sort, :page => params[:page], :per_page => @option.disp_rows
	render :controller => '/admin/archives', :action => :index and return
      end
    elsif  params[:id] && params[:id] != 'reservation_id'
      debug "params id is #{params[:id]}"
      @archive = Archive.find(params[:id])
    elsif params[:archive][:reservation_id]
      debug "params[:archive][:reservation_id] is #{params[:archive][:reservation_id]}"
      @archive = Archive.find_by_reservation_id(params[:archive][:reservation_id])
    end
    if @archive
      @page_title = "Archived Reservation #{@archive.reservation_id}"
      @payments = @archive.payments
      @reservation = Reservation.find @archive.reservation_id
    elsif @archives.size > 0
      @page_title = "Archived Reservations"
    else
      if params[:archive][:reservation_id]
	flash[:error] = "archive record for reservation #{params[:archive][:reservation_id]} not found"
      end
      redirect_to admin_archives_url
    end
  rescue ActiveRecord::RecordNotFound
    @reservation = false
    flash[:error] = 'archive record not found'
    redirect_to admin_archives_url
  rescue => err
    @reservation = false
    error "archive record not found: #{err}"
    flash[:error] = 'archive record not found'
    redirect_to admin_archives_url
  end

  def update
    debug "params[:id] is #{params[:id]}"
    if params[:id]
      case params[:id]
      when 'res'
	@option.update_attributes :archive_list_sort => "reservation_id, id ASC"
      when 'name'
	@option.update_attributes :archive_list_sort => "name ASC"
      when 'start'
	@option.update_attributes :archive_list_sort => "startdate ASC"
      when 'end'
	@option.update_attributes :archive_list_sort => "enddate ASC"
      when 'space'
	@option.update_attributes :archive_list_sort => "space_name ASC"
      when 'all'
	Archive.all.each { |a| a.update_attribute :selected, true }
      when 'clear'
	Archive.all.each { |a| a.update_attribute :selected,  false }
      end
      redirect_to admin_archives_url
    end
  end

  def select
    a = Archive.find(params[:id].to_i)
    a.update_attribute :selected, !a.selected
    render(:nothing => true) 
  end

  def destroy
    if params[:id] == 'delete'
      Archive.find_all_by_selected(true).each do |a|
	debug "#{a.id} selected"
	a.destroy
      end
    else
      Archive.find(params[:id]).destroy
    end
    redirect_to admin_archives_url
  end

  def download
    csv_string = 'name,address,address2,city,state,mail_code,country,email,phone,phone_2, '
    csv_string << 'startdate, enddate, '
    csv_string << 'vehicle_license,vehicle_state,vehicle_license_2,vehicle_state_2,'
    csv_string << 'rigtype_name,slides,length,rig_age,'
    csv_string << 'adults,pets,kids,'
    csv_string << 'space_name,deposit,total_charge,tax_str,'
    csv_string << 'group_name,discount_name,special_request,close_reason,canceled,'
    csv_string << 'idnumber,log,recommender,seasonal'
    csv_string << "\n"

    #data
    Archive.find_all_by_selected(true).each do |a|
      debug "#{a.id} selected"
      csv_string << "\"#{a.name}\",\"#{a.address}\",\"#{a.address2}\",\"#{a.city}\",\"#{a.state}\",\"#{a.mail_code}\",\"#{a.country}\",\"#{a.email}\",\"#{a.phone}\",\"#{a.phone_2}\","
      csv_string << "\"#{a.startdate}\",\"#{a.enddate}\","
      csv_string << "\"#{a.vehicle_license}\",\"#{a.vehicle_state}\",\"#{a.vehicle_license_2}\",\"#{a.vehicle_state_2}\","
      csv_string << "\"#{a.rigtype_name}\",\"#{a.slides}\",\"#{a.length}\",\"#{a.rig_age}\","
      csv_string << "\"#{a.adults}\",\"#{a.pets}\",\"#{a.kids}\",\"#{a.space_name}\","
      csv_string << "\"#{a.deposit}\",\"#{a.total_charge}\",\"#{a.tax_str}\","
      csv_string << "\"#{a.group_name}\",\"#{a.discount_name}\",\"#{a.special_request}\",\"#{a.close_reason}\",\"#{a.canceled}\","
      csv_string << "\"#{a.idnumber}\",\"#{a.log}\",\"#{a.recommender}\",\"#{a.seasonal}\"\n"
    end

    send_data csv_string,
	    :type => 'text/csv;charset=iso-8859-1;header=present',
	    :disposition => 'attachment; filename=Archive.csv'
  end

end
