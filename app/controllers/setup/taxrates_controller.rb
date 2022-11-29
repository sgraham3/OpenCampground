class Setup::TaxratesController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

#####################################################
# Tax Rates
#####################################################
  def index
    @page_title = 'List of Taxes'
    @taxes = Taxrate.all
  end

  def sort
    @page_title = 'Update sort order of taxes'
    @taxes = Taxrate.all
  end

  def resort
    pos = 1
    params[:taxes].each do |id|
      Taxrate.update(id, :position => pos)
      pos += 1
    end
    redirect_to sort_setup_taxrates_path
  end
      
  def new
    @page_title = 'Create a new tax'
    @taxrate = Taxrate.new
  end

  def create
    @taxrate = Taxrate.create!(params[:taxrate])
    flash[:notice] = "Tax #{@taxrate.name} was successfully created."
    redirect_to setup_taxrates_path
  rescue
    @page_title = 'Create a new tax'
    @taxrate = Taxrate.new
    render :action => 'new'
  end

  def edit
    @page_title = 'Edit a tax'
    @taxrate = Taxrate.find(params[:id])
  end

  def update
    @taxrate = Taxrate.find(params[:id])
    if @taxrate.update_attributes(params[:taxrate])
      flash[:notice] = "Taxrate #{@taxrate.name} was successfully updated."
      redirect_to setup_taxrates_path
    else
      @page_title = 'Edit a tax'
      render :action => :edit
    end
  end

  def destroy
    @taxrate = Taxrate.find(params[:id])
    name = @taxrate.name
    if @taxrate.destroy
      flash[:notice] = "Taxrate #{name} was successfully deleted."
    else
      flash[:error] = "Deletion of #{name} failed."
    end
    redirect_to setup_taxrates_path
  end
end
