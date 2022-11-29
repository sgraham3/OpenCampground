class Setup::PricesController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

#####################################################
# Prices
#####################################################
  def index
    @page_title = 'Prices'
    @seasons = Season.active(:order => "id asc")
    @storage = @option.use_storage?
    @seasonal = @option.use_seasonal?
    @count = 3
    @count += 1 if @seasonal
    @count += 1 if @storage
    @count += 6 if @option.variable_rates?
    # debug "count is #{@count}"
  end

  def show
    @rates = Rate.find_current(params[:id])
    session[:season_id] = params[:id]
    unless @rates.size > 0
      # if the rate is currently empty copy it from the 
      # default rate for a starting point
      season = Season.find(params[:id])
      Rate.find_current(1).each do |r|
	new_rate = Rate.new(:season_id => season.id,
			    :price_id => r.price_id,
			    :daily_rate => r.daily_rate,
			    :weekly_rate => r.weekly_rate,
			    :monthly_rate => r.monthly_rate,
			    :seasonal_rate => r.seasonal_rate,
			    :monthly_storage => r.monthly_storage,
			    :sunday => r.sunday,
			    :monday => r.monday,
			    :tuesday => r.tuesday,
			    :wednesday => r.wednesday,
			    :thursday => r.thursday,
			    :friday => r.friday,
			    :saturday => r.saturday)
	new_rate.save
      end
      @rates = Rate.find_current(params[:id])
    end
    render :update do |page|
      page.replace_html('prices', :partial => 'rate', :object => @rates)
    end
  end

  def new
    @page_title = 'Add a new price group'
    @rate = Rate.new
    @season = Season.first
  end

  def create
    warnings = ''
    if params[:price][:name] == ""
      flash[:error] = "Creation of new price failed. A unique name is required"
      redirect_to new_setup_price_url and return
    end
 
    Price.transaction do
      begin
	price = Price.create!(params[:price])
	logger.info "price created #{price.inspect}"
      rescue
	logger.info "price creation failed"
	flash[:error] = "Creation of price failed. Make sure name is unique"
	redirect_to new_setup_price_url and return
      end
      begin
	@rate = Rate.create!(params[:rate].merge({:price_id => price.id, :season_id => session[:season_id]}))
	logger.info "rate created #{@rate.inspect}"
	flash[:notice] = "Price #{@rate.price.name} was successfully created."
	warnings += "No daily rate defined   " unless @rate.daily_rate > 0
	warnings += "No weekly rate defined   " unless @rate.weekly_rate > 0
	warnings += "No monthly rate defined   " unless @rate.monthly_rate > 0
	flash[:warning] = warnings unless warnings.empty?
      rescue
	flash[:error] = "Creation of price failed. Make sure name is unique"
	redirect_to new_setup_price_url and return
      end
      # also add the rate to each of the other seasons..add to all
      Season.all.each do |s|
	unless s == @rate.season
	  r = Rate.create!( :price_id => @rate.price_id,
			    :season_id => s.id,
			    :daily_rate => @rate.daily_rate,
			    :weekly_rate => @rate.weekly_rate,
			    :monthly_rate => @rate.monthly_rate,
			    :seasonal_rate => @rate.seasonal_rate,
			    :monthly_storage => @rate.monthly_storage,
			    :sunday => @rate.sunday,
			    :monday => @rate.monday,
			    :tuesday => @rate.tuesday,
			    :wednesday => @rate.wednesday,
			    :thursday => @rate.thursday,
			    :friday => @rate.friday,
			    :saturday => @rate.saturday)
	end
      end
    end
    redirect_to setup_prices_url
  end

  def old_edit
    # I don't see any way this is used
    @page_title = 'Edit a price group'
    @rate = Rate.find_current_rate(session[:season_id], params[:id])
    @price = @rate.price
    @season = session[:season_id]
    @seasons = Season.active(:order => "id asc")
  end

  def edit
    @page_title = 'Edit price'
    @rate = Rate.find_current_rate(params[:season_id], params[:id])
    @price = @rate.price
    @season = Season.find params[:season_id]
    session[:season_id] = @season.id
    @seasons = Season.active(:order => "id asc")
    render :edit
  end

  def update
    @price = Price.find(params[:id])
    if @price.name != params[:price][:name]
      @price.update_attributes(params[:price])
    end
    @rate = Rate.find_current_rate(session[:season_id], params[:id])
    @rate.daily_rate = params[:rate][:daily_rate].to_f
    @rate.weekly_rate = params[:rate][:weekly_rate].to_f
    @rate.monthly_rate = params[:rate][:monthly_rate].to_f
    @rate.seasonal_rate = params[:rate][:seasonal_rate].to_f if @option.use_seasonal
    @rate.monthly_storage = params[:rate][:monthly_storage].to_f if @option.use_storage
    if @option.variable_rates
      @rate.sunday = params[:rate][:sunday].to_f
      @rate.monday = params[:rate][:monday].to_f
      @rate.tuesday = params[:rate][:tuesday].to_f
      @rate.wednesday = params[:rate][:wednesday].to_f
      @rate.thursday = params[:rate][:thursday].to_f
      @rate.friday = params[:rate][:friday].to_f
      @rate.saturday = params[:rate][:saturday].to_f
    end
    if @rate.save
      flash[:notice] = "Price #{@rate.price.name} for season #{@rate.season.name} was successfully updated."
    else
      flash[:error] = "Update of price #{@rate.price.name} for season #{@rate.season.name} failed."
    end
    Rate.find_all_by_price_id(@price.id).each do |rate|
      rate.update_attribute :seasonal_rate, params[:rate][:seasonal_rate].to_f if @option.use_seasonal && rate.seasonal_rate == 0.0
      rate.update_attribute :monthly_storage, params[:rate][:monthly_storage].to_f if @option.use_storage && rate.monthly_storage == 0.0
    end
    redirect_to setup_prices_url
  end

  def destroy
    price = Price.find(params[:id])
    name = price.name
    sp = Space.find_all_by_price_id(price.id)
    if sp.size == 0
      if price.destroy
        flash[:notice] = "Price #{name} was successfully deleted."
      else
        flash[:error] = "Deletion of #{name} failed."
      end
    else
      flash[:error] = "Price #{name} in use by spaces: "
      sp.each do |s|
        flash[:error] += s.name + ' '
      end
    end
    redirect_to setup_prices_url
  end
end
