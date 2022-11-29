# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  # helper :all # include all helpers, all the time
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details

  require 'fileutils'
  include MyLib
  include CalculationHelper
  before_filter :option, :except => :handle_bogus
  before_filter :need_ssl, :except => [:ipn, :handle_bogus]
  before_filter :set_cache_buster, :except => [:ipn, :handle_bogus]
  before_filter :set_locale, :except => [:ipn, :handle_bogus]
  before_filter :startup, :except => [:update_dates, :update_sitetype, :calendar_end_update, :calendar_update, :date_end_update, :date_update, :ipn, :handle_bogus]
  before_filter :display_control, :except => [:ipn, :handle_bogus]
  before_filter :set_current_user, :except => [:login, :initdemo, :find_remote, :create_remote, :ipn, :handle_bogus]
  # before_filter :authorize
  after_filter  :save_state, :except => [:partial_update, :destroy, :create, :calendar_update, :calendar_end_update, :date_end_update, :date_update, :update_week_year, :update_week_number, :update_week_count, :ipn, :handle_bogus]
  helper_method :error, :debug, :info

  DB_VERSION = 108

  require 'rake'
  require 'rake/testtask'
  require 'rdoc/task'
  require 'tasks/rails'
  require 'date'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  # filter_parameter_logging :password, :credit_card_no
  # filter_parameter_logging :value unless Rails.env.development?
  filter_parameter_logging :account unless Rails.env.development?

  def update_dates
    ####################################################
    # validate and update only the changed dates
    ####################################################
    @reservation = reservation
    # validate the proposed dates
    storage = false
    storage = params[:reservation][:storage] if defined? params[:reservation][:storage]
    seasonal = false
    seasonal = params[:reservation][:seasonal] if defined? params[:reservation][:seasonal]
    debug "update_dates: storage = #{storage.to_s}, seasonal = #{seasonal.to_s}"
    if (@reservation.startdate != @date_start) || (@reservation.enddate != @date_end) || (@reservation.seasonal != seasonal) || (@reservation.storage != storage)
      debug 'update_dates: Dates changed'
      # the stay was changed
      @reservation.camper.active if @reservation.camper
      @reservation.startdate = @date_start
      @reservation.enddate = @date_end
      @reservation.seasonal = seasonal
      @reservation.storage = storage
      if Campground.open?(@reservation.startdate, @reservation.enddate)
	@reservation.save!
        debug 'saved reservation'
	debug 'update_dates: Campground open...updating'
	@reservation.add_log("dates changed") if @reservation.confirm?
	@skip_render = true
	recalculate_charges
      else
        # debug 'update_dates: Campground closed'
	flash[:error] = I18n.t('reservation.Flash.SpaceUnavailable') +
			"<br />" +
			I18n.t('reservation.Flash.ClosedDates',
			    :closed => DateFmt.format_date(@option.closed_start,'long'),
			    :open => DateFmt.format_date(@option.closed_end,'long'))
      end 
    end
  rescue
    flash[:error] = ' '
    @reservation.errors.each {|attr, msg| flash[:error] += " #{msg}" }
    error flash[:error]
  ensure
    if @remote
      redirect_to :action => :space_selected
    elsif session[:current_action]
      redirect_to :action => session[:current_action], :reservation_id => @reservation.id
    else
      redirect_to :action => :list
    end
  end


  def update_sitetype
    debug "#update_sitetype"
    if params[:sitetype_id]
      desired = params[:sitetype_id]
    else
      desired = 0
    end
    session[:desired_type] = desired
    begin
      if params[:reservation_id]
        @reservation = Reservation.find params[:reservation_id]
	session[:reservation_id] = @reservation.id
      elsif session[:reservation_id]
        @reservation = Reservation.find session[:reservation_id]
      else
	@reservation = Reservation.new :startdate => session[:startdate], :enddate => session[:enddate]
      end
    rescue => err
      @reservation = Reservation.new :startdate => session[:startdate], :enddate => session[:enddate]
    end
    update_display_dates(false)
  end

  def calendar_end_update
    if defined?(params[:date]) && !params[:date].empty?
      begin
	enddate = DateCds.parse_cds(params[:date])
      rescue
	enddate = Date.parse(params[:date])
      end
      debug "enddate is #{enddate}"
      # if we have not gone to index/show first like abandon and backspace
      # session[:startdate] will not be defined
      if session[:startdate]
	startdate = session[:startdate].to_date
      else
	startdate = Date.today
	session[:startdate] = startdate.to_s
      end
      unless enddate > startdate
        enddate = startdate +1
      end
    else
      enddate = Date.tomorrow
      startdate = Date.today
      session[:startdate] = startdate.to_s
    end
    if session[:reservation_id]
      @reservation = Reservation.find session[:reservation_id].to_i
      @reservation.startdate = startdate
      @reservation.enddate = enddate
    else
      @reservation = Reservation.new :startdate => startdate, :enddate => enddate
    end
    session[:enddate] = enddate.to_s
    debug "calendar_end_update: start = #{startdate}, end = #{enddate}"
    update_display_dates
  rescue => err
    error  'calendar_end_update: ' + err.to_s
    # we will just ignore if we ended up with a bad date
    # but we have saved the data in the session
    render(:nothing => true)
  end

  def calendar_update
    # updates startdate from calendar date select
    # need to add checking for closed..
    debug 'calendar_update:'
    if defined?(params[:date]) && !params[:date].empty?
      debug 'calendar_update: have date in params'
      begin
	startdate = DateCds.parse_cds(params[:date])
      rescue
	startdate = Date.parse(params[:date])
      end
      debug "startdate is #{startdate}"
      startdate = currentDate if startdate < currentDate && @remote
      debug 'calendar_update: startdate ' + startdate.to_s
      # if we have not gone to index/show first like abandon and backspace
      # session[:enddate] will not be defined
      if session[:enddate]
	enddate = session[:enddate].to_date
      else
	enddate = startdate + 1.day
	session[:enddate] = enddate.to_s
      end
      unless defined?(enddate) && enddate > startdate
	enddate = startdate + 1.day
	session[:enddate] = enddate.to_s
      end
      debug 'calendar_update: enddate ' + enddate.to_s
      session[:startdate] = startdate.to_s
    else
      startdate = currentDate
      enddate = startdate + 1
      session[:startdate] = startdate.to_s
      session[:enddate] = enddate.to_s
    end
    if session[:reservation_id]
      debug "reservation from session is #{session[:reservation_id]}"
      @reservation = Reservation.find session[:reservation_id].to_i
      @reservation.startdate = startdate
      @reservation.enddate = enddate
    else
      debug 'no reservation in session'
      @reservation = Reservation.new :startdate => startdate, :enddate => enddate
    end
    debug "calendar_update: start = #{startdate}, end = #{enddate}"
    update_display_dates
  rescue => err
    error  'calendar_update: ' + err.to_s
    # we will just ignore if we ended up with a bad date
    # but we have saved the data in the session
    render(:nothing => true)
  end

  def date_end_update
    flash[:error] = ''
    flash[:notice] = ''
    startdate = session[:startdate] ? session[:startdate].to_date : currentDate
    enddate = session[:enddate] ? session[:enddate].to_date : startdate + 1.day
    debug "start date is #{startdate}, end date is #{enddate}"
    if params.key?(:day) && params[:day] != "null"
      day = params[:day].to_i
      begin
	enddate = enddate.change(:day => day)
      rescue ArgumentError => err
        enddate = cleanup_day(enddate, day)
      end
    end
    if params.key?(:month) && params[:month] != "null"
      month = params[:month].to_i
      begin
	enddate = enddate.change(:month => month)
      rescue ArgumentError => err
        enddate = cleanup_month(enddate, month)
      end
    end
    if params.key?(:year) && params[:year] != "null"
      year = params[:year].to_i
      begin
        enddate = enddate.change(:year => year)
      rescue ArgumentError => err
        enddate = cleanup_year(enddate, year)
      end
    end
    debug "end date now #{enddate}, start date now #{startdate}"
    if enddate <= startdate
      enddate = startdate + 1.day
    end
    if session[:reservation_id]
      @reservation = Reservation.find session[:reservation_id].to_i
      @reservation.update_attributes :enddate => enddate, :startdate => startdate
    else
      @reservation = Reservation.new :enddate => enddate, :startdate => startdate
    end
    session[:enddate] = enddate.to_s
    session[:startdate] = startdate.to_s
    update_display_dates
  rescue => err
    error 'date_end_update: ' + err.to_s
    # we will just ignore if we ended up with a bad date
    # but we have saved the data in the session
    render(:nothing => true)
  end

  def date_update
    # update the start date
    flash[:error] = ''
    flash[:notice] = ''
    startdate = session[:startdate] ? session[:startdate].to_date : currentDate
    enddate = session[:enddate] ? session[:enddate].to_date : startdate + 1.day
    debug "start date is #{startdate}, end date is #{enddate}"
    if params.key?(:day) && params[:day] != "null"
      day = params[:day].to_i
      begin
	startdate = startdate.change(:day => day)
	debug "changed startdate to #{startdate}"
      rescue ArgumentError => err
        startdate = cleanup_day(startdate, day)
      end
      startdate = currentDate if startdate < currentDate && @remote
    end
    if params.key?(:month) && params[:month] != "null"
      month = params[:month].to_i
      begin
	startdate = startdate.change(:month => month)
      rescue ArgumentError => err
        startdate = cleanup_month(startdate, month)
      end
      if startdate < currentDate && @remote
	startdate = currentDate 
	flash[:error] += "reservation start date in the past is not allowed"
      end
    end
    if params.key?(:year) && params[:year] != "null"
      year = params[:year].to_i
      begin
        startdate = startdate.change(:year => year)
      rescue ArgumentError => err
        startdate = cleanup_year(startdate, year)
      end
    end
    debug "start date is #{startdate}, end date is #{enddate}"
    if startdate < currentDate && @remote
      debug "startdate less than current date"
      startdate = currentDate
      flash[:error] += I18n.t('reservation.Flash.EarlyStart')
    end
    if startdate >= enddate
      debug "startdate >= enddate"
      enddate = startdate + 1.day
    end
    debug "start date is #{startdate}, end date is #{enddate}"
    if session[:reservation_id]
      debug "updating reservaton with sd = #{startdate}, ed = #{enddate}"
      @reservation = Reservation.find session[:reservation_id].to_i
      @reservation.update_attributes :startdate => startdate, :enddate => enddate
    else
      @reservation = Reservation.new :startdate => startdate, :enddate => enddate
    end
    session[:startdate] = startdate
    session[:enddate] = enddate
    update_display_dates
  rescue => err
    error 'date_update: ' + err.to_s
    # we will just ignore if we ended up with a bad date
    # but we have saved the data in the session
    render(:nothing => true)
  end

  def update_week_year
    if params[:year]
      session[:year] = params[:year] 
    else
      session[:year] = currentDate.year unless session[:year]
    end
    @reservation = Reservation.new
    @reservation.startdate, @reservation.enddate = dates_from_week(session[:year].to_i, session[:number].to_i, session[:count].to_i)
    session[:startdate] = @reservation.startdate
    session[:enddate] = @reservation.enddate
    update_display_dates
  rescue => err
    error "exception #{err.class}: #{err.message}"
    # we will just ignore if we ended up with a bad date
    # but we have saved the data in the session
    render(:nothing => true)
  end

  def update_week_number
    session[:number] = params[:number] if params.key?(:number)
    session[:number] = 1 unless session[:number]
    @reservation = Reservation.new
    @reservation.startdate, @reservation.enddate = dates_from_week(session[:year].to_i, session[:number].to_i, session[:count].to_i)
    session[:startdate] = @reservation.startdate
    session[:enddate] = @reservation.enddate
    update_display_dates
  rescue => err
    error "exception #{err.class}: #{err.message}"
    # we will just ignore if we ended up with a bad date
    # but we have saved the data in the session
    render(:nothing => true)
  end

  def update_week_count
    session[:count] = params[:count] if params.key?(:count)
    session[:count] = 1 unless session[:count]
    @reservation = Reservation.new
    @reservation.startdate, @reservation.enddate = dates_from_week(session[:year].to_i, session[:number].to_i, session[:count].to_i)
    session[:startdate] = @reservation.startdate
    session[:enddate] = @reservation.enddate
    update_display_dates
  rescue => err
    error "exception #{err.class}: #{err.message}"
    # we will just ignore if we ended up with a bad date
    # but we have saved the data in the session
    render(:nothing => true)
  end

  def cookies_test
    debug 'cookies_test:'
    if request.cookies[SESSION_KEY].blank?
      info "cookies_test: cookies disabled for #{request.remote_ip}"
      render :file => "/403.html", :layout => false, :status => 403
    else
      if @remote
	redirect_to session[:return_to] || :controller => :remote, :action => :index
      else
	redirect_to session[:return_to] || :controller => :reservation, :action => :list
      end
      session[:return_to] = nil
    end
  end

  def restart(redir = true)
    if (@os != 'Windows_NT') && (ENV["SERVER_SOFTWARE"] =~ /Apache/)
      info 'Restarting'
      FileUtils::rm 'tmp/restart.txt', :force => true
      FileUtils::touch 'tmp/restart.txt'
      if redir
	redirect_to :controller => :admin, :action => :index   and return
      end
    else
      if flash[:notice]
	flash[:notice] += ' ' + I18n.t('notice.Restart')
      else
	flash[:notice] = I18n.t('notice.Restart')
      end
    end
  end

protected
################################################
# none of these methods are externally visible
################################################
  def check_for_conflict
    if Conflict::double_booking.size > 0
      debug 'startup: conflicts found'
      flash[:error] = "<b>reservation conflicts found!  Go to <a href=\"#{maintenance_conflicts_path}\">Conflicts</a> to resolve.</b>"
      error 'reservation conflicts found'
    end
  end

  def update_display_dates(display_dates = true)
    if @remote
      @spaces  = Space.available_remote( @reservation.startdate, @reservation.enddate, session[:desired_type])
    else
      @spaces  = Space.available( @reservation.startdate, @reservation.enddate, session[:desired_type])
    end
    @count  = @spaces.size 
    debug "update_display_dates: #{@count} spaces available"
    display_count = show_available?
    render :update do |page|
      if flash[:error]
	page[:flash].replace_html flash[:error]
	flash[:error] = nil
	page[:flash][:style][:color] = 'red'
	page[:flash].visual_effect :highlight
      elsif flash[:warning]
	page[:flash].replace_html flash[:warning]
	flash[:warning] = nil
	page[:flash][:style][:color] = 'yellow'
	page[:flash].visual_effect :highlight
      elsif flash[:notice]
	page[:flash].replace_html flash[:notice]
	flash[:notice] = nil
	page[:flash][:style][:color] = 'green'
	page[:flash].visual_effect :highlight
      end
      page[:count].replace_html :partial => 'shared/count' if display_count
      page[:spaces].replace_html :partial => 'space_pulldown' if session[:express]
      page[:dates].replace_html :partial => 'shared/dates' if display_dates
    end
  end

  def cookies_required
    debug 'cookies_required:'
    return unless request.cookies[SESSION_KEY].blank?
    session[:return_to] = request.request_uri
    redirect_to :action => :cookies_test
  end

private

  #####################################################
  # something is wrong with this date.  We will return
  # a date corrected to be valid.  Usually a problem
  # with the number of days in a month
  #####################################################
  def cleanup_day(dt, day)
    if day < 1
      dt = dt.change(:day => 1)
    else
      dt = dt.change(:day => dt.end_of_month.day)
    end
  end
  def cleanup_month(dt, month)
    newdate = dt.change(:day => 1, :month => month)
    cleanup_day(newdate, dt.day)
  end
  def cleanup_year(dt, year)
    newdate = dt.change(:day => 1, :year => year)
    cleanup_day(newdate, dt.day)
  end

  #####################################################
  # clean up any left over/abandoned reservations that
  # are not confirmed and are older than 30 minutes
  #####################################################
  def cleanup_abandoned
    Reservation.all(:conditions => [ "CONFIRM = ? and updated_at < ? and archived = ?", false, 30.minutes.ago, false]).each do |r|
      debug "cleanup_abandoned: deleting #{r.id}"
      Reason.close_reason_is "abandoned"
      begin
	r.archive
      rescue RuntimeError => err
	error 'Cleanup: ' + err.to_s
      rescue ActiveRecord::StaleObjectError => err
	error 'Cleanup: ' + err.to_s
	locking_error(r)
      end
    end
  end

  ########################
  # cp Logo to images
  #######################
  def check_logo
    if(ds = DynamicString.find_by_name("Logo.png"))
      debug "Found #{ds.name}"
      if File.exists?(Rails.root.join('public','images','Logo.png'))
	if ds.updated_at == nil || ds.updated_at > File.ctime(Rails.root.join('public','images','Logo.png'))
	  # Logo.png has been changed
	  f = File.new(Rails.root.join('public','images','Logo.png'), "w")
	  f.syswrite(ds.text)
	  f.close
	  ds.update_attributes :updated_at => Time.now if ds.updated_at == nil
	  debug "updated #{ds.name}"
	end
      else
	f = File.new(Rails.root.join('public','images','Logo.png'), "w")
	f.syswrite(ds.text)
	f.close
	ds.update_attributes :updated_at => Time.now if ds.updated_at == nil
	debug "created #{ds.name}"
      end
      File.delete(Rails.root.join('public','images','Logo.jpg')) if File.exists?(Rails.root.join('public','images','Logo.jpg'))
    elsif(ds = DynamicString.find_by_name("Logo.jpg"))
      debug "Found #{ds.name}"
      if File.exists?(Rails.root.join('public','images','Logo.jpg'))
	if ds.updated_at == nil || ds.updated_at > File.ctime(Rails.root.join('public','images','Logo.jpg'))
	  # Logo.jpg has been changed
	  f = File.new(Rails.root.join('public','images','Logo.jpg'), "w")
	  f.syswrite(ds.text)
	  f.close
	  ds.update_attributes :updated_at => Time.now if ds.updated_at == nil
	  debug "updated #{ds.name}"
	end
      else
	f = File.new(Rails.root.join('public','images','Logo.jpg'), "w")
	f.syswrite(ds.text)
	f.close
	ds.update_attributes :updated_at => Time.now if ds.updated_at == nil
	debug "created #{ds.name}"
      end
      File.delete(Rails.root.join('public','images','Logo.png')) if File.exists?(Rails.root.join('public','images','Logo.png'))
    else
      # neither are found
      fn = Rails.root.join('public','images','Logo.jpg')
      File.delete fn if File.exists? fn
      fn = Rails.root.join('public','images','Logo.png')
      File.delete fn if File.exists? fn
    end
  end

  def show_available?
    @remote ? @option.show_remote_available : @option.show_available
  end

  def is_remote?
    # is this a remote reservation
    if params[:controller] == 'remote'
      debug 'is_remote?: true'
      return true
    elsif session[:remote]
      debug 'is_remote?: true'
      return true
    else
      debug 'is_remote?: false'
      return false
    end
  end

  def is_local?
    # is this an office login
    return false if params[:controller] == 'remote'
    return false if session[:remote]
    return true
  end
  
  def update_maps
    begin
      if @option.map && !@option.map.empty? && !File::exists?(Rails.root.join('public','map',@option.map)) && File::exists?(Rails.root.join('public','images',@option.map))
	# copy file to new location
	debug 'update_maps: copying map ' + @option.map
	FileUtils::cp(Rails.root.join('public','images',@option.map), Rails.root.join('public','map',@option.map))
      end
    rescue => err
      error 'problem copying map ' + err.to_s
    end
    begin
      if @option.remote_map && !@option.remote_map.empty? && !File::exists?(Rails.root.join('public','map',@option.remote_map)) && File::exists?(Rails.root.join('public','images',@option.remote_map))
	# copy file to new location
	debug 'update_maps: copying remote_map ' + @option.remote_map
	FileUtils::cp(Rails.root.join('public','images',@option.remote_map), Rails.root.join('public','map',@option.remote_map))
      end
    rescue => err
      error 'problem copying remote map ' + err.to_s
    end
  end

  def sanitize_filename(file_name)
    # get only the filename, not the whole path (from IE)
    just_filename = File.basename(file_name) 
    # replace all none alphanumeric, underscore or perioids
    # with underscore
    just_filename.sub(/[^\w\.\-]/,'_') 
  end

  def dates_from_week(year=currentDate.year, week_no=0, count=0)
    debug "dates_from_week: year is #{year}, week is #{week_no}, count is #{count}"
    sd = Date::commercial(year, week_no, 1)
    ed = Date::commercial(year, week_no + count, 1)
    return sd, ed
  end

  def set_cache_buster
    # debug 'set_cache_buster:'
    if is_local?
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    end
  end

  def debug(str = ' ')
    if str
      logger.debug "Debug: #{controller_name}##{action_name} " + str
    else
      logger.debug "Debug: #{controller_name}##{action_name} "
    end
  rescue => err
    logger.error 'Error in debug: ' + err.to_s
  end

  def info(str = ' ')
    if str
      logger.info "Info #{Time.now.strftime('%d-%m-%y %H%M')}: #{controller_name}##{action_name} " + str
    else
      logger.info "Info #{Time.now.strftime('%d-%m-%y %H%M')}: #{controller_name}##{action_name} "
    end
  rescue => err
    logger.error 'Error in info: ' + err.to_s
  end

  def error(str = ' ')
    if str
      logger.error "Error #{Time.now.strftime('%d-%m-%y %H%M')}: #{controller_name}##{action_name} " + str
    else
      logger.error "Error #{Time.now.strftime('%d-%m-%y %H%M')}: #{controller_name}##{action_name} "
    end
  rescue => err
    logger.error 'Error in error: ' + err.to_s
  end

  def reject
  end

  ################################
  # calculate extra charges
  ################################
  def calculate_extras(res_id)
    debug "calculate_extras:"
    ec = ExtraCharge.find_all_by_reservation_id  res_id
    # debug "found #{ec.size} extra charges" unless ec.size.zero?
    extra_charges = 0.0
    ec.each do |e|
      # debug e.inspect
      e.save_charges(e.number)
      extra_charges += (e.charge + e.monthly_charges + e.weekly_charges + e.daily_charges)
      debug "calculate_extras: Extra charges are #{extra_charges}"
    end
    return extra_charges
  end

  ################################################
  # filters
  ################################################

  def proceed
    # info 'proceed'
    # info "proceed is #{session[:proceed]}, reservation_id is #{session[:reservation_id]}"
    if @remote
      redirect_to :action => :index, :controller => :remote and return unless session[:proceed]
    end
  end

  def need_ssl
    if @option.use_ssl?
      redirect_to :protocol => "https://" unless request.ssl?
    else
      redirect_to :protocol => "http://" if request.ssl?
    end
  rescue
    # use ssl not defined.  Cause db migration
    info 'no ssl'
    session[:top] = nil
  end

  def set_current_user
    debug 'set_current_user:'
    User.current = nil
    return if (@remote || (params[:controller] == 'setup/dynamic_strings' && params[:action] == 'send_files'))
    if @option.use_login?
      User.current = session[:user_id]
      @user_login = User.find User.current
    else
      session[:user_id] = nil
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to(:controller => '/login', :action => 'login') and return
  end

  # see if this user is authorized to do admin functions
  def authorize
    debug 'authorize:'
    unless User.authorized? params[:controller], params[:action], params[:func]
      flash[:error] = I18n.t('general.Flash.NotAuth')
      debug 'authorize: not authorized'
      raise "User not authorized"
    end
    debug 'authorize: authorized'
    true
  rescue => err
    error 'authorize: ' + err.to_s
    redirect_to :controller => 'reservation', :action => 'list'
  end

  def login_from_cookie
    debug 'login_from_cookie:'
    debug "login_from_cookie: use_login is #{@option.use_login.to_s}, #{is_local? ? 'local' : 'remote' }"
    return unless is_local?
    return unless @option and @option.use_login? and @option.use_autologin? and cookies[:auth_token] and session[:user_id].nil?
    user = RememberLogin.find_by_token(cookies[:auth_token])
    if user
      # debug 'login_from_cookie: user is: ' + user.inspect
      # debug 'login_from_cookie: user.user is: ' + user.user.inspect
      # debug "login_from_cookie: user is #{user.user.name}" if user.user
      session[:user_id] = user.user_id
    end
  end

  def startup
    #####################################################
    # set the session variable so we know we have done
    # initialization.
    # we will not attempt migration unless we have a new
    # session
    #####################################################
    debug 'startup:'
    if (params[:action] == 'express') && (params[:controller] == 'reservation')
      debug 'startup: setting express'
      session[:express] |= true
      debug 'startup:' + session[:express].to_s
    else
      # debug 'startup: not setting express'
      session[:express] = nil
    end
    # debug 'startup: cookie verifier secret = ' + ActionController::Base.cookie_verifier_secret || 'Error: no secret'
    unless session[:top]
      info "New session"
      info "Startup with release #{OC_RELEASE}, version #{OC_VERSION}"
      Dir::chdir Rails.root
      session[:top] = true

      if is_local?
	#####################################################
	# clean out the dynamic store cache
	#####################################################
	if File::directory? 'public/dynamic'
	  Dir::entries('public/dynamic').each do |f|
	    if File::file? 'public/dynamic/' + f
	      File::delete 'public/dynamic/' + f
	    end
	  end
	end
	#####################################################
	# Fetch the current version of the database and if
	# it is not the same as DB_VERSION migrate to that
	# version.
	#####################################################
	current = TopMigrator.new("db/migrate/", 0)
	debug "startup: Current database version is #{current.version}"
	db_current = current.version
	if db_current != DB_VERSION
	  info "Migrating database to version #{DB_VERSION}"
	  Rake::Task['db:migrate'].invoke
	  restart
	else
	  check_logo
	  ########################
	  # update the maps locations
	  ########################
	  debug 'startup: update maps'
	  update_maps
	  begin
	    @option = Option.first unless defined?(@option)
	  rescue
	  end
	  ########################
	  # cleanup old leftover space_alloc
	  ########################
	  debug 'startup: cleanup old leftover space_alloc'
	  SpaceAlloc.destroy_all ["updated_at < ?", currentDate.yesterday]
	  ########################
	  # cleanup old reservations past retention date
	  ########################
	  debug 'startup: cleanup old reservations past retention date'
	  Reservation.destroy_all(["archived = ? and updated_on < ?", true, currentDate.months_ago(@option.keep_reservations.to_i)])
	  ########################
	  # get rid of bogus archives
	  ########################
	  debug 'startup: get rid of bogus archives'
	  Archive.destroy_all("reservation_id = 0")
	  ########################
	  # cleanup incomplete payments
	  ########################
	  debug 'startup: cleanup incomplete payments'
	  pmt = Payment.all(:conditions => ["amount = ? and created_at < ? and credit_card_no = ? and cc_fee = ?", 0.0, Time.now.yesterday, "", 0.0])
	  debug 'startup:' + pmt.size.to_s + ' found'
	  pmt.each do |p|
	    if p.memo.blank?
	      debug 'startup: ' + p.reservation_id.to_s 
	      p.destroy
	    end
	  end
	  ########################
	  # move charges from measured_charge to charge
	  ########################
	  debug 'startup: move charges from measured_charge to charge'
	  ExtraCharge.all(:conditions => ["measured_charge != ?", 0.0]).each { |e| e.update_attributes :charge => e.measured_charge, :measured_charge => 0.0 }
	  # correct error where in an earlier version we ended up with charge for OCCASIONAL both in charges and daily_charges
	  Extra.find_all_by_extra_type(Extra::OCCASIONAL).each do |e|
	    ExtraCharge.all(:conditions => "extra_id = #{e.id} AND daily_charges != 0.0").each {|ec| ec.update_attributes :daily_charges => 0.0}
	  end
	  ########################
	  # clean up unused extra charges
	  ########################
	  debug 'startup: clean up unused extra charges'
	  old = ExtraCharge.all :include => ["extra"],
				:conditions => ["initial = ? and final = ? and updated_on < ? and extras.extra_type = ?", 0.0, 0.0, currentDate, Extra::MEASURED]
	  old.each do |o|
	    begin
	      o.destroy
	    rescue
	      debug 'startup: ' + o.inspect
	    end
	  end
	end
      end
      redirect_to :controller => :remote, :action => :index unless is_local?
    end
    @option = Option.first unless defined?(@option)
  rescue => err
    error "exception #{err.class}: #{err.message}"
    flash[:error] = I18n.t('error.Application')
  end

  def option
    debug 'option:'
    @option = Option.first unless defined?(@option)
    if ENV["OS"] && ENV["OS"] == "Windows_NT"
      @os = 'Windows_NT'
    else
      @os = 'Linux'
    end
    debug 'option: OS is ' + @os
    if is_remote?
      @remote = true
    else
      @remote = false
    end
  rescue ActiveRecord::StatementInvalid => err
    # database has not been setup
    Rake::Task['db:reset'].invoke
    restart
    Option.reset_column_information
    @option = Option.first
  end

  def set_locale
    debug "set_locale:"
    session[:locale] = params[:locale] if params[:locale]
    I18n.locale = session[:locale] || @option.locale
    # I18n.locale = session[:locale] || I18n.default_locale
    debug "set_locale: locale is #{I18n.locale}"

    locale_path = "#{LOCALES_DIRECTORY}#{I18n.locale}.yml"

    unless I18n.load_path.include? locale_path
      I18n.load_path << locale_path
      I18n.backend.send(:init_translations)
    end

  rescue => err
    error "exception #{err.class}: #{err.message}"
    flash.now[:notice] = "#{I18n.locale} translation not available"
    I18n.load_path -= [locale_path]
    # I18n.locale = session[:locale] = @option.default_locale
    I18n.locale = session[:locale] || I18n.default_locale
  end

  def check_login
    debug "check_login:"
    ###############################################
    # use login if use_login is turned on
    ###############################################
    return if params[:action] == 'cookies_test'
    debug 'check_login: not in cookies_test'
    redirect_to(:controller => '/login', :action => 'login') and return unless is_local?
    debug 'check_login: not is_local?'
    if @option.use_login?
      debug 'check_login: using login'
      if session[:user_id] == nil
        debug 'check_login: not logged in'
	# user is not logged in so go to login
	redirect_to :controller => '/login', :action => 'login'
      else
        debug 'check_login: logged in'
	unless defined? @user_login
	  debug 'check_login: got to find user'
	  @user_login = User.find(session[:user_id].to_i)
	end
      end
    else
      # make sure user_id is not saved if we are
      debug 'check_login: not using login'
      session[:user_id] = nil
    end
  rescue ActiveRecord::RecordNotFound => err
    error "exception #{err.class}: #{err.message} .. redirecting to login"
    redirect_to :controller => '/login', :action => 'login'
  rescue => err
    error "exception #{err.class}: #{err.message}"
  end

  def save_state
    ###############################################
    # save the controller and action for possible
    # later use
    ###############################################
    session[:controller] = params[:controller]
    session[:action] = params[:action]
    #
    #
  rescue => err
    error "exception #{err.class}: #{err.message}"
  end

  def display_control
    # debug 'display_control:'
    # debug "display_control: next_action is #{session[:next_action]}"
    agent = request.user_agent
    chk = (agent =~ /Mobi|Android/)
    if chk
      @mobile = true
    else
      @mobile = false
    end
    debug "display_control: mobile is #{@mobile}"
    debug "display_control: user agent is #{agent}"
    @use_navigation = true
    if agent =~ /Mobile/
      @browser = :mobile_safari
    elsif agent =~ /Chrome/
      # debug "display_control: Chrome"
      @browser = :chrome
    elsif agent =~ /Safari/
      @browser = :safari
    elsif agent =~ /Opera/
      @browser = :opera
    elsif agent =~ /MSIE/
      @browser = :msie
    elsif agent =~ /Firefox/
      # debug "display_control: Firefox"
      @browser = :ffox
    else
      @browser = :unknown
    end
    debug "display_control: browser is #{@browser}"
  end

  ################################################
  # methods for all AR derived classes
  ################################################

  def log_state
    #debug "log_state: next controller is #{session[:next_controller]}, next action is #{session[:next_action]}"
  end

  def check_dates
    ###############################################
    # check reservation start and end dates for 
    # validity and for logic
    ###############################################
    errors=""
    bogus_start_date = false
    bogus_end_date = false
    ###############################################
    # other than initial fetch skip this validation
    ###############################################
    if params[:page]
      return true
    end
    # first test the startdate
    if params[:reservation]
      begin
	if params[:reservation][:"startdate(1i)"]
	  @date_start = Date.new(params[:reservation][:"startdate(1i)"].to_i,
				params[:reservation][:"startdate(2i)"].to_i,
				params[:reservation][:"startdate(3i)"].to_i)
	else
	  @date_start = Date.parse params[:reservation][:startdate]
	end
      rescue
	errors += I18n.t('general.Flash.WrongStart')
	@date_start = Date.new # bogus date
	bogus_start_date = true
      end
      # then check the enddate
      begin
	if params[:reservation][:"enddate(1i)"]
	  @date_end   = Date.new(params[:reservation][:"enddate(1i)"].to_i,
				params[:reservation][:"enddate(2i)"].to_i,
				params[:reservation][:"enddate(3i)"].to_i)
	else
	  @date_end = Date.parse params[:reservation][:enddate]
	end
      rescue
	errors += I18n.t('general.Flash.WrongEnd')
	@date_end = Date.new # bogus date
	bogus_end_date = true
      end
      if (@date_end && @date_start) && @date_end <= @date_start
	debug "startdate is #{@date_start} and enddate is #{@date_end}"
	errors += I18n.t('general.Flash.EqualDates') unless bogus_start_date || bogus_end_date
      end
      unless errors.empty?
	info errors
	flash[:error] = errors
	redirect_to :controller => session[:controller], :action => session[:action] and return
      end
    end
  end

  ###############################################
  # reduce logging in production mode
  ###############################################
  def local_request?
    false
  end

  def locking_error(res)
    ####################################################
    # Handle an error with record locking
    ####################################################
    flash[:error] = I18n.t('error.Conflict')
    if res.checked_in?
      redirect_to :controller => 'reservation', :action => 'in_park'
    else
      redirect_to :controller => 'reservation', :action => 'list'
    end
  end

  def return_here
    #####################################################
    # save location to return to
    #####################################################
    session[:next_action] = params[:action]
    session[:next_controller] = params[:controller]
  end

  def clear_session
    # clear out things that are specific to some action/sequence
    # Keep only these
    # session[:locale]
    # session[:top]
    # session[:user_id]
    # set this one to office state
    session[:remote] = false
    #
    session[:action] = nil
    session[:a_page] = nil
    session[:camper_found] = nil
    session[:canx_action] = nil
    session[:canx_controller] = nil
    session[:change] = nil
    session[:city] = nil
    session[:combine] = nil
    session[:controller] = nil
    session[:count] = nil
    session[:current_action] = nil
    session[:current_controller] = nil
    session[:day] = nil
    session[:desired_type] = nil
    session[:early_date] = nil
    session[:ec] = nil
    session[:enddate] = nil
    session[:express] = nil
    session[:fini_action] = nil
    session[:f_name] = nil
    session[:group_id] = nil
    session[:late_date] = nil
    session[:list] = nil
    session[:month] = nil
    session[:name] = nil
    session[:next_action] = nil
    session[:next_controller] = nil
    session[:number] = nil
    session[:page] = nil
    session[:page_title] = nil
    session[:payment_id] = nil
    session[:proceed] = nil
    session[:reservation_id] = nil
    session[:return_to] = nil
    session[:season] = nil
    session[:seasonal] = nil
    session[:startdate] = nil
    session[:storage] = nil
    session[:year] = nil
  end

  class TopMigrator < ActiveRecord::Migrator
  #####################################################
  # a class to perform migrations without intervention
  # by the user so we get to the proper version of the
  # database
  #####################################################
    def version
      self.current_version
    end
  end

end
