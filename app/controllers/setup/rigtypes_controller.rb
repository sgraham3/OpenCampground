class Setup::RigtypesController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

#####################################################
# Rigtypes
#####################################################
  def index
    @page_title = 'Types of rigs'
    @rigtypes = Rigtype.all
  end

  def sort
    @page_title = 'Update sort order of rig types'
    @rigtypes = Rigtype.all
  end

  def resort
    pos = 1
    params[:rigtypes].each do |id|
      Rigtype.update(id, :position => pos)
      pos += 1
    end
    redirect_to sort_setup_rigtypes_path 
  end
      
  def new
    @page_title = 'Add new rig type'
    @rigtype = Rigtype.new
  end

  def create
    @rigtype = Rigtype.new(params[:rigtype])
    if @rigtype.save
      flash[:notice] = "Rigtype #{@rigtype.name} was successfully created."
    else
      flash[:error] = "Creation of #{@rigtype.name} failed. Make sure name is unique"
    end
    redirect_to setup_rigtypes_path 
  end

  def edit
    @page_type = 'Edit rig type'
    @rigtype = Rigtype.find(params[:id])
  end

  def update
    @rigtype = Rigtype.find(params[:id])
    if @rigtype.update_attributes(params[:rigtype])
      flash[:notice] = "Rigtype #{@rigtype.name} was successfully updated."
    else
      flash[:error] = "Update of #{@rigtype.name} failed."
    end
    redirect_to setup_rigtypes_path
  end

  def destroy
    @rigtype = Rigtype.find(params[:id])
    @rigtype.destroy
    if @rigtype.errors.count.zero?
      flash[:notice] = "Rigtype #{@rigtype.name} was deleted."
    else
      debug @rigtype.errors.full_messages[0]
      (msg,comma,junk) = @rigtype.errors.full_messages[0].rpartition ','
      flash[:error] = msg + '. Recommend you change active to false.'
    end
    redirect_to setup_rigtypes_path
  end

end
