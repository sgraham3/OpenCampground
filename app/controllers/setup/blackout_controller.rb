class Setup::BlackoutController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

  # GET /setup_blackouts
  def index
    @page_title = 'Blackout Dates'
    b = Blackout.first
    @setup_blackouts = Blackout.all
  end

  # GET /setup_blackouts/new
  def new
    @blackout = Blackout.new
  end

  # GET /setup_blackouts/1/edit
  def edit
    @blackout = Blackout.find(params[:id])
  end

  # POST /setup_blackouts
  def create
    @blackout = Blackout.new(params[:blackout])
    if @blackout.save
      flash[:notice] = "Blackout #{@blackout.name} was successfully created."
      redirect_to setup_blackout_index_url
    else
      render :action => "new"
    end
  end

  # PUT /setup_blackouts/1
  def update
    @blackout = Blackout.find(params[:id])
    if @blackout.update_attributes(params[:blackout])
      flash[:notice] = "Blackout #{@blackout.name} was successfully updated."
      redirect_to setup_blackout_index_url
    else
      render :action => "edit"
    end
  end

  # DELETE /setup_blackouts/1
  def destroy
    @blackout = Blackout.find(params[:id])
    @blackout.destroy
    flash[:notice] = "Blackout #{@blackout.name} was successfully destroyed."
    redirect_to setup_blackout_index_url
  end
end
