class Setup::SpacesController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

#####################################################
# Spaces
#####################################################
  def index
    new
    @page_title = 'List of sites in park'
    @spaces = Space.all
  end

  def sort
    @page_title = 'Update sort order of spaces'
    @spaces = Space.all
  end

  def resort
    pos = 1
    params[:spaces].each do |id|
      Space.update(id, :position => pos)
      pos += 1
    end
    redirect_to sort_setup_spaces_path
  end
      

  def show
    @space = Space.find(params[:id])
  end

  def create
    @space = Space.new(params[:space])
    if @space.save
      flash[:notice] = "Space #{@space.name} was successfully created."
      session[:last_space] = @space.id
    else
      flash[:error] = 'Creation of new space failed: ' + @space.errors.full_messages[0]
    end
    redirect_to setup_spaces_path
  end

  def edit
    @page_title = 'Edit an existing space'
    @space = Space.find(params[:id])
    @sitetypes = Sitetype.all(:order => "id asc")
    @prices = Price.all(:order => "id asc")
  end

  def update
    @space = Space.find(params[:id])
    if @space.update_attributes(params[:space])
      flash[:notice] = "Space #{@space.name} was successfully updated."
      redirect_to setup_spaces_path
    else
      flash[:error] = 'Space update failed: ' + @space.errors.full_messages[0]
      redirect_to edit_setup_space_path(@space.id)
    end
  end

  def destroy
    @space = Space.find(params[:id])
    @space.destroy
    if @space.errors.count.zero?
      flash[:notice] = "Space #{@space.name} was deleted."
    else
      debug @space.errors.full_messages[0]
      (msg,comma,junk) = @space.errors.full_messages[0].rpartition ','
      flash[:error] = msg + '. Recommend you change active to false.'
    end
    redirect_to setup_spaces_path
  end

  def new
    @page_title = 'Define a new site'
    if session[:last_space]
      begin
	@space = Space.find(session[:last_space]).clone
	@space.name = ''
      rescue
	@space = Space.new
      end
    else
      @space = Space.new
    end
    @sitetypes = Sitetype.all(:order => "id asc")
    @prices = Price.all(:order => "id asc")
    if @prices.size == 0
      flash[:error] = "You must have at least one price defined"
      redirect_to setup_spaces_path
    end
  end

end
