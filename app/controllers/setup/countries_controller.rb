class Setup::CountriesController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

#####################################################
# Countries
#####################################################
  # setup_countries GET
  def index
    @page_title = 'Countries currently available'
    @countries = Country.all
  end

  # new_setup_country GET
  def new
    @page_title = 'Define a new Country'
    @country = Country.new
  end

  # setup_countries POST
  def create
    @country = Country.new(params[:country])
    if @country.save
      flash[:notice] = "Country #{@country.name} was successfully created."
    else
      flash[:error] = 'Creation of new country failed. Make sure name is unique'
    end
    redirect_to setup_countries_path
  end

  # edit_setup_country GET
  def edit
    @page_title = 'Edit a current country'
    @country = Country.find(params[:id])
  end

  # setup_country PUT
  def update
    @country = Country.find(params[:id])
    if @country.update_attributes(params[:country])
      flash[:notice] = "Country #{@country.name} was successfully updated."
    else
      flash[:error] = 'Update of country failed.'
    end
    redirect_to setup_countries_path
  end

  # setup_country DELETE
  def destroy
    country = Country.find(params[:id])
    name = country.name
    c = Camper.find_all_by_country_id(country.id)
    if c.size == 0
        if country.destroy
	flash[:notice] = "Country #{name} was successfully destroyed."
      else
	flash[:error] = 'Deletion of country failed.'
      end
    else
      flash[:error] = "Country #{name} in use"
    end
    redirect_to setup_countries_path
  end

  # sort_setup_countries GET
  def sort
    @page_title = 'Update sort order of countries'
    @countries = Country.all
  end

  # resort_setup_countries GET
  def resort
    pos = 1
    params[:countries].each do |id|
      Country.update(id, :position => pos)
      pos += 1
    end
    redirect_to sort_setup_countries_path
  end
      
end
