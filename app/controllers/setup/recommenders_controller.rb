class Setup::RecommendersController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

#####################################################
# Recommenders
#####################################################
  def index
    @page_title = 'List of recommenders'
    @recommenders = Recommender.all
  end

  # get sort_setup_recommenders_path
  def sort
    @page_title = 'Update sort order of recommenders'
    @recommenders = Recommender.all
  end

  # get resort_setup_recommenders_path
  def resort
    pos = 1
    params[:recommenders].each do |id|
      Recommender.update(id, :position => pos)
      pos += 1
    end
    redirect_to sort_setup_recommenders_path
  end
      
  def new
    @page_title = 'Create a new recommender'
    @recommender = Recommender.new
  end

  def create
    @recommender = Recommender.new(params[:recommender])
    if @recommender.save
      flash[:notice] = "Recommender #{@recommender.name} was successfully created."
    else
      flash[:error] = "Creation of #{@recommender.name} failed. Make sure name is unique"
    end
    redirect_to setup_recommenders_path
  end

  def edit
    @page_title = 'Edit a recommender'
    @recommender = Recommender.find(params[:id])
  end

  def update
    @recommender = Recommender.find(params[:id])
    if @recommender.update_attributes(params[:recommender])
      flash[:notice] = "Recommender #{@recommender.name} was successfully updated."
    else
      flash[:error] = "Update of #{@recommender.name} failed."
    end
    redirect_to setup_recommenders_path
  end

  def destroy
    @recommender = Recommender.find(params[:id])
    @recommender.destroy
    if @recommender.errors.count.zero?
      flash[:notice] = "recommender #{@recommender.name} was deleted"
    else
      debug @recommender.errors.full_messages[0]
      (msg,comma,junk) = @recommender.errors.full_messages[0].rpartition ','
      flash[:error] = msg + '. Recommend you change active to false.'
    end
    redirect_to setup_recommenders_path
  end

end
