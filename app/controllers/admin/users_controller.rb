class Admin::UsersController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  # GET /users
  # GET /users.xml
  def index
    @page_title = I18n.t('titles.UserList')
    @users = User.all(:order => :name)
  end

  def list
    redirect_to admin_users_url
  end

  # GET /admin_users/new
  # GET /admin_users/new.xml
  def new
    @page_title = I18n.t('titles.UserNew')
    @user = User.new
  end

  # GET /users/edit
  def edit
    @page_title = I18n.t('titles.UserEdit')
    @user = User.find(params[:id].to_i)
    @user_login = User.find User.current
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    if @user.save
      flash[:notice] = I18n.t('user.Flash.Created', :name => @user.name)
      redirect_to admin_users_url
    else
      @page_title = I18n.t('titles.UserNew')
      flash[:error] = I18n.t('user.Flash.CreateFailed')
      error 'create failed'
      render :action => "new"
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    if User.find(User.current).admin?
      @user = User.find(params[:id].to_i)
    else
      @user = User.find(User.current)
    end
    if @user.update_attributes(params[:user])
      flash[:notice] = I18n.t('user.Flash.Updated', :name => @user.name)
      if User.find(User.current).admin?
	redirect_to(admin_users_url)
      else
	redirect_to(:controller => '/reservation', :action => :list) 
      end
    else
      flash[:error] = I18n.t('user.Flash.UpdateFailed')
      error 'update failed'
      redirect_to edit_admin_user_url(@user.id)
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id].to_i) 
    if @user.destroy
      flash[:notice] = I18n.t('user.Flash.Destroyed')
    else
      flash[:error] = I18n.t('user.Flash.DestroyFailed')
      error 'destroy failed'
    end
    redirect_to admin_users_url
  end
end
