class Maintenance::TroubleshootController < ApplicationController
  require 'fileutils'
  before_filter :login_from_cookie
  before_filter :check_login

  def index
    @page_title = "Troubleshoot"
    res_array = []
    grp_array = []
    reservations = Reservation.find :all, :conditions => ["archived = ?", false], :include => ['camper', 'space'], :order => "space_id ASC"
    reservations.each do  |res|
      if res.space_id == 0
        debug 'space id 0'
        res_array << res.id
      elsif res.camper_id == 0 
        debug 'camper id 0'
        res_array << res.id
      elsif !res.confirm?
        debug 'not confirmed'
        res_array << res.id
      else
        begin
	  xx = res.camper.last_name
	  yy = res.space.name
        rescue 
          res_array << res.id
        end      
      end
    end
    @res_size = res_array.size
    debug "#{@res_size} reservations with problems"

    groups = Group.find :all, :include => ['camper']
    groups.each do |grp|
      if grp.camper_id == 0
        debug 'wagonmaster id 0'
        grp_array << grp.id
      elsif grp.expected_number < 0 
	grp.update_attributes :expected_number => Reservation.find_all_by_group_id(grp.id).count
	debug 'expected number ' + grp.expected_number.to_s
	grp_array << grp.id if grp.expected_number < 0 
      else
        begin
	  xx = grp.camper.last_name
        rescue 
          grp_array << grp.id
        end      
      end
    end

    err = ''
    if (res_array.size == 0) && (grp_array.size == 0)
      flash[:notice] = "No problem reservations or groups found"
      redirect_to maintenance_index_path and return
    end
    if res_array.size > 0
      err += "#{res_array.size} problem reservations found "
      @reservations = Reservation.find res_array
    end
    if grp_array.size > 0
      err += "#{grp_array.size} problem groups found"
      @groups = Group.find grp_array
    end
    flash[:error] = err if err.size > 0
  end

  def destroy
    if params[:reservation]
      destroy_res
    else
      destroy_grp
    end
    redirect_to maintenance_troubleshoot_index_path
  end

  private

  def destroy_res
    res = Reservation.find params[:id]
    res.destroy
    flash[:notice] = "reservation #{params[:id]} destroyed"
    info "reservation #{params[:id]} destroyed"
  rescue
    flash[:warning] = 'failed to destroy reservation ' + params[:id]
    error 'failed to destroy res ' + params[:id]
  end

  def destroy_grp
    grp = Group.find params[:id]
    grp.destroy
    unless grp.errors.empty?
      flash[:warning] = "#{grp.name} could not be destroyed. There are probably reservations in the group"
    else
      flash[:notice] = "#{grp.name} group destroyed"
      info "group #{params[:id]} destroyed"
    end
  rescue
    flash[:warning] = 'failed to destroy group ' + params[:id]
    error 'failed to destroy group ' + params[:id]
  end

end

