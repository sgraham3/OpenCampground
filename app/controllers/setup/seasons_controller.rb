class Setup::SeasonsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

#####################################################
# Seasons
#####################################################
  def index
    @page_title = 'List of Seasons'
    @seasons = Season.all(:order => "startdate asc")
  end

  def new
    @page_title = 'Add a new Season'
    @season = Season.new
  end

  def create
    @season = Season.new(params[:season])
    if @season.save
      flash[:notice] = "Season #{@season.name} was successfully created."
      # we have to create a default price entry when we create the season
      r = Rate.find_current(1)
      r.each do |rate|
	new_rate = Rate.new(:season_id => @season.id,
			    :price_id => rate.price_id,
			    :daily_rate => rate.daily_rate,
			    :weekly_rate => rate.weekly_rate,
			    :monthly_rate => rate.monthly_rate)
	new_rate.save
      end
    else
      flash[:error] = "Creation of season #{@season.name} failed. Make sure name is unique and end date is later than start date"
    end
    redirect_to setup_seasons_url
  end

  def edit
    @page_title = 'Edit a Season'
    @season = Season.find(params[:id])
  end

  def update
    @season = Season.find(params[:id])
    if @season.update_attributes(params[:season])
      flash[:notice] = "Season #{@season.name} was successfully updated."
    else
      flash[:error] = "Season #{@season.name} update failed."
    end
    redirect_to setup_seasons_url
  end

  def destroy
    season = Season.find(params[:id])
    name = season.name
    charge = Charge.find_all_by_season_id(season.id)
    if charge.size > 0
      flash[:warning] = "Season in use by following reservations:"
      first = Season.first
      charge.each do |chg| 
        flash[:warning] += " #{chg.reservation_id}"
	chg.update_attribute :season_id, first.id
      end
    end
    rates = Rate.find_all_by_season_id(season.id)
    rates.each do |r|
      r.destroy
    end
    if season.destroy
      session[:season_id] = "1"
      flash[:notice] = "Season #{name} was successfully deleted."
    else
      flash[:error] = "Deletion of #{name} failed."
    end
    redirect_to setup_seasons_url
  end
end
