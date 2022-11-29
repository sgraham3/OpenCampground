class CamperController < ApplicationController
  before_filter :login_from_cookie, :except => [:find_remote, :create_remote]
  before_filter :check_login, :except => [:find_remote, :create_remote, :partial_update]
  before_filter :proceed

  in_place_edit_for :camper, :first_name
  in_place_edit_for :camper, :address
  in_place_edit_for :camper, :address2
  in_place_edit_for :camper, :city
  in_place_edit_for :camper, :state
  in_place_edit_for :camper, :mail_code
  in_place_edit_for :camper, :email
  in_place_edit_for :camper, :phone
  in_place_edit_for :camper, :phone_2
  in_place_edit_for :camper, :idnumber
  in_place_edit_for :camper, :notes
  in_place_edit_for :camper, :addl
  
  layout :determine_layout
  
  def new
    @camper = Camper.new
  end

  def index
    flash[:warning] = I18n.t('error.Application')
    error "entered from #{session[:controller]} #{session[:action]}"
    redirect_to :action => 'list'
  end

  def create_remote
    if params[:reservation_id] && params[:reservation_id] != ''
      @reservation = Reservation.find params[:reservation_id]
    else
      @reservation = Reservation.find(session[:reservation_id].to_i)
    end
    debug "reservation is #{@reservation.id}"
    if params[:id] # we are reusing a camper from the last reservation
      @camper = Camper.find(params[:id])
      debug "found camper #{@camper.id}"
    elsif params[:camper] # we need to create a camper
      @camper = Camper.new(params[:camper])
      if @camper.save
	debug "created camper #{@camper.id}"
	flash[:notice] = I18n.t('camper.Flash.Created', :camper_name => @camper.full_name)
      else
	flash[:error] = I18n.t('camper.Flash.CreateFail', :camper_name => @camper.full_name)
	@page_title = I18n.t('titles.CamperName')
	begin
	  @prompt = Prompt.find_by_display_and_locale!('find_remote', I18n.locale.to_s)
	rescue
	  @prompt = Prompt.find_by_display_and_locale('find_remote', 'en')
	end
	render :action => :find and return
      end
    else
      error "no camper or id params"
      redirect_to :action => :find_remote, :reservation_id => session[:reservation_id].to_i and return
    end
    @reservation.update_attributes :camper_id => @camper.id
    if @option.allow_gateway? || @option.require_gateway?
      redirect_to :controller => :remote, :action => :payment and return
    else
      redirect_to :controller => :remote, :action => :confirm_without_payment and return
    end
  rescue ActiveRecord::RecordNotFound => err
    error err.to_s
    redirect_to :controller => :remote, :action => :index  and return
  rescue ActiveRecord::RecordNotSaved => err
    error err.to_s
    flash[:error] = I18n.t('camper.Flash.CreateFail', :camper_name => @camper.full_name) + err
    redirect_to :action => :find_remote
  end

  def create
    if params[:single]
      # debug 'in single'
      @camper = Camper.new params[:camper]
      if @camper.save
        # debug 'save succeeded'
	flash[:notice] = "Creation of camper record for #{@camper.full_name} succeeded"
	redirect_to new_setup_camper_url and return
      else
        # debug 'save failed'
	flash[:error] = I18n.t('camper.Flash.CreateFail', :camper_name => @camper.full_name)
        render :action => :new and return
      end
    end
    unless params[:camper]
      error "no params[:camper]"
      redirect_to :action => :find, :reservation_id => session[:reservation_id].to_i and return
    end
    if params[:reservation_id] && params[:reservation_id] != ''
      @reservation = Reservation.find params[:reservation_id]
    else
      @reservation = Reservation.find(session[:reservation_id].to_i)
    end
    debug "reservation id is #{params[:reservation_id]}"
    @camper = Camper.new(params[:camper])
    if @camper.save
      flash[:notice] = I18n.t('camper.Flash.Created', :camper_name => @camper.full_name)
      @reservation.update_attributes :camper_id => @camper.id
      debug "confirm is #{@reservation.confirm}"
      debug 'group' if session[:group_id]
    else
      render :action => :find and return
    end
    if @reservation.confirm == true
      # must be here from reservation show change camper.
      redirect_to :controller => 'reservation', :action => 'update_camper',  :camper_id => @camper.id, :reservation_id => @reservation.id and return
    elsif session[:group_id]
      # must be here as part of a group res wagonmaster creation.
      debug 'creating wagonmaster'
      redirect_to :controller => 'group_res', :action => 'create',  :camper_id => @camper.id, :reservation_id => @reservation.id and return
    else
      debug 'finished __create... now redirecting to confirm_res'
      redirect_to :controller => 'reservation', :action => 'confirm_res', :camper_id => @camper.id, :reservation_id => @reservation.id and return
    end
  rescue ActiveRecord::RecordNotFound => err
    error err.to_s
    redirect_to :controller => :reservation, :action => :list and return
  rescue ActiveRecord::RecordNotSaved => err
    error err.to_s
    flash[:error] = I18n.t('camper.Flash.CreateFail', :camper_name => @camper.full_name) + err
    redirect_to :action => 'find'
  end

  def change
    session[:next_action] = 'update_camper'
    session[:next_controller] = 'reservation'
    session[:change] = true
    begin
      reservation_id = params[:reservation_id].to_i
      session[:reservation_id] = reservation_id.to_s
    rescue
      error 'no reservation_id in params'
      reservation_id = session[:reservation_id].to_i
    end
    redirect_to :action => :find, :reservation_id => reservation_id
  end

  def find_remote
    @page_title = I18n.t('titles.CamperName')
    @gateway = Integration.first.name
    begin
      @prompt = Prompt.find_by_display_and_locale!('find_remote', I18n.locale.to_s)
    rescue
      @prompt = Prompt.find_by_display_and_locale('find_remote', 'en')
    end
    __find
    @old_camper = Camper.find session[:camper_id] if session[:camper_id]
    render :action => :find
  rescue => err
    error err.to_s
    flash[:error] = I18n.t('reservation.Flash.NotFound', :id => params[:reservation_id])
    redirect_to :controller => :remote, :action => :index 
  end

  def find
    @page_title = (session[:page_title] ||= I18n.t('titles.SelCreateCamper'))
    __find
    @campers = Array.new
    session[:reservation_id] = params[:reservation_id] unless session[:reservation_id]
    @reservation_id = session[:reservation_id]
  rescue => err
    error err.to_s
    flash[:error] = I18n.t('reservation.Flash.NotFound', :id => session[:reservation_id])
    redirect_to :controller => :reservation, :action => :list 
  end

  def __find
    session[:page_title] = nil
    if params[:reservation_id] && params[:reservation_id] != ''
      @reservation = Reservation.find params[:reservation_id]
      session[:reservation_id] = params[:reservation_id]
    else
      @reservation = Reservation.find session[:reservation_id]
    end
    @use_navigation = false
  end

  def find_camper
    @page_title = I18n.t('titles.find_camper')
    @campers = []
    session[:next_controller] = 'camper'
    session[:next_action] = 'find_camper'
    session[:page_title] = nil
  end

  def partial_update
    @reservation_id = session[:reservation_id]
    f_name = session[:f_name]
    city = session[:city]
    name = params[:camper_last_name] || session[:name]
    db_config = ActiveRecord::Base.configurations[Rails.env]
    unless name.empty?
      session[:name] = name
      if db_config['adapter'] == 'sqlite3'
	@campers = Camper.paginate(:page => params[:page], :per_page => @option.disp_rows - 3,
                                   :conditions => ['LOWER(last_name) LIKE ? OR LOWER(last_name) GLOB ?',
                                                   "#{name}%", "[a-z]+ #{name}[a-z ]."],
                                   :order => 'last_name, first_name asc', :include => ["country"])
      else
	@campers = Camper.paginate(:page => params[:page], :per_page => @option.disp_rows - 3,
                                   :conditions => ['LOWER(last_name) LIKE ? OR LOWER(last_name) RLIKE ?',
                                                   "#{regex_clean(name)}%", "[a-z]+ #{regex_clean(name)}[a-z ]."],
                                   :order => 'last_name, first_name asc', :include => ["country"])
      end
    end
    if params[:page]
      @page_title = I18n.t('titles.find_camper')
      @camper = Camper.new :last_name => name, :first_name => f_name, :city => city
      render :action => :find_camper
    else
      render :partial => 'campers', :layout => false
    end
  end

  def partial_update_first
    f_name = params[:camper_first_name] || session[:f_name]
    city = session[:city]
    name = session[:name]
    unless f_name.empty?
      session[:f_name] = f_name
      @campers = Camper.paginate(:page => params[:page], :per_page => @option.disp_rows - 3,
                                 :conditions => ['(LOWER(last_name) LIKE ? OR LOWER(last_name) RLIKE ?) AND LOWER(first_name) LIKE ?',
                                                 "#{name}%", "[a-z]+ #{regex_clean(name)}[a-z ].", "#{f_name}%"],
                                 :order => 'last_name, first_name asc')
    end
    if params[:page]
      @page_title = I18n.t('titles.find_camper')
      @camper = Camper.new :last_name => name, :first_name => f_name, :city => city
      render :action => :find_camper
    else
      render :partial => 'campers', :layout => false
    end
  end

  def partial_update_city
    city = params[:camper_city] || session[:city]
    name = session[:name]
    f_name = session[:f_name]
    unless city.empty?
      session[:city] = city
      @campers = Camper.paginate(:page => params[:page], :per_page => @option.disp_rows - 3,
                                 :conditions => ['(LOWER(last_name) LIKE ? OR LOWER(last_name) RLIKE ?) AND LOWER(first_name) LIKE ? AND LOWER(city) LIKE ?',
                                                 "#{name}%", "[a-z]+ #{regex_clean(name)}[a-z ].", "#{f_name}%", "#{city}%"],
                                 :order => 'last_name, first_name asc')
    end
    if params[:page]
      @page_title = I18n.t('titles.find_camper')
      @camper = Camper.new :last_name => name, :first_name => f_name, :city => city
      render :action => :find_camper
    else
      render :partial => 'campers', :layout => false
    end
  end

  def partial_update_id
    @reservation_id = session[:reservation_id]
    number = params[:camper_idnumber]
    unless params[:camper_idnumber].empty?
      @campers = Camper.paginate(:page => params[:page], :per_page => @option.disp_rows - 3,
                                 :conditions => ['LOWER(idnumber) LIKE ?', "#{number}%"],
                                 :order => 'last_name, first_name asc')
    end
    if params[:page]
      @page_title = I18n.t('titles.find_camper')
      render :action => :find_camper
    else
      render :partial => 'campers', :layout => false
    end
  end

  def list
    @page_title = I18n.t('titles.campers')
    if (params[:camper] && params[:camper][:phone]) || params[:phone]
      if params[:phone]
        number = params[:phone]
      else
        number = params[:camper][:phone]
      end
      campers = Camper.all(:conditions => ["phone like ?", "%#{number}"],
			    :order => "last_name, first_name asc",
			    :include => 'country')
      debug "found #{campers.size} campers with phone of #{number}"
      if campers.size == 1
	redirect_to :controller => :camper, :action => :show,  :camper_id => campers[0].id and return
      elsif campers.size == 0
	debug "no camper found with phone number #{number}"
	flash[:warning] = "no camper found with phone number #{number}"
	redirect_to :action => :find_camper and return
      else
	flash[:warning] = "#{campers.size} campers found with phone number #{number}"
	# which camper do you want
	@campers = campers.paginate( :page => params[:page], :per_page => @option.disp_rows)
      end
      session[:next_action] = 'find_camper'
    else
      @campers = Camper.paginate( :page => params[:page], :per_page => @option.disp_rows,
				  :order => "last_name, first_name asc",
				  :include => 'country')
      session[:next_action] = 'list'
    end
    session[:next_controller] = 'camper'
    ####################################################
    # return to here from a camper show
    ####################################################
    session[:camper_found] = 'list'
  end

  def last_used
    @page_title = I18n.t('titles.CamperByActivity')
    @campers = Camper.paginate(:page => params[:page], :per_page => @option.disp_rows,
                               :order => "activity, last_name, first_name asc")
    render :action => :list
  end

  def combine
    @page_title = I18n.t('titles.CombineCampers')
    if params[:page]
      page = params[:page]
      session[:page] = page
    else
      page = session[:page]
    end
    # this is the camper that will be deleted
    @combine = Camper.find(params[:camper_id].to_i)
    session[:combine] = @combine.id
    @campers = Camper.paginate(:page => page, :per_page => @option.disp_rows,
                               :order => "last_name, first_name asc")
  end

  def do_combine
    camper = Camper.find(params[:camper_id].to_i)
    combine = Camper.find(session[:combine].to_i)
    # put all of the reservations for combine to camper
    res = Reservation.find_all_by_camper_id combine.id
    debug res.size.to_s + ' reservations to update'
    res.each do |r|
      r.update_attributes :camper_id => camper.id
    end
    grp = Group.find_all_by_camper_id combine.id
    debug grp.size.to_s + ' groups to update'
    grp.each do |g|
      g.update_attributes :camper_id => camper.id
    end
    if (res.size + grp.size) > 0
      res[0].camper.active
    end
    destroy_camper 'list', combine
  end

  def show
    @page_title = I18n.t('titles.ShowCamper')
    @camper = Camper.find(params[:camper_id].to_i)
    reservations = Reservation.find_all_by_camper_id_and_confirm @camper.id, true
    @reservations = reservations if reservations.size > 0
  end

  def destroy
    camper = Camper.find(params[:camper_id].to_i)
    destroy_camper 'list', camper
  end

  def destroy_inactive
    camper = Camper.find(params[:camper_id].to_i)
    destroy_camper 'last_used', camper
  end

  def set_camper_last_name
    # Parameters: {"action"=>"set_camper_last_name",
    #              "id"=>"4",
    #              "value"=>"",
    #              "controller"=>"reservation",
    #              "editorId"=>"camper_last_name_4_in_place_editor"}
    unless [:post, :put].include?(request.method) then
      return render(:text => 'Method not allowed', :status => 405)
    end
    @item = Camper.find(params[:id].to_i)
    err = @item.update_attributes :last_name => params[:value]
    unless err
      @item.reload
    end
    render :text => CGI::escapeHTML(@item.last_name.to_s)
  end

  def update_country
    @camper = Camper.find(params[:id].to_i)
    @camper.update_attributes :country_id => params[:country_id].to_i
    render(:nothing => true)
  end 

  private

  def determine_layout
    case params[:action]
    when "find_remote", "create_remote"
      'remote'
    else
      'application'
    end
  end

  def destroy_camper (next_action, camper)
    camper.destroy
    if camper.errors.count.zero?
      flash[:notice] = I18n.t('camper.Flash.Deleted', :camper_name => camper.full_name)
    else
      fl = ''
      camper.errors.full_messages.each do |m|
        (msg,comma,junk) = m.rpartition ','
	fl += msg + ' '
      end
      fl += I18n.t('camper.Flash.DeleteFailed', :camper_name => camper.full_name)
      flash[:error] = fl
    end
    redirect_to :action => next_action
  rescue StaleObjectError => err
    flash[:error] = I18n.t('camper.Flash.ChangeFail')
    error  err.to_s
    redirect_to :action => next_action
  end

  def locking_error(cmpr)
    ####################################################
    # Handle an error with record locking
    ####################################################
    flash[:error] = I18n.t('camper.Flash.ChangeFail')
  end

end
