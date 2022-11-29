class Setup::PromptsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize
  DISPLAYS= %w{ confirmation find_space index show wait_for_confirmation find_remote payment CardConnect-a-payment CardConnect-payment PayPal-a-payment PayPal-payment old-show}

  def create
    @prompt = Prompt.new(params[:prompt])
    if @prompt.save
      flash[:notice] = "Prompt #{@prompt.display}, #{@prompt.locale} was successfully created."
    else
      flash[:error] = 'Creation of new prompt failed.'
    end
    redirect_to setup_prompts_path
  end

  def destroy
    prompt = Prompt.find(params[:id])
    display = prompt.display
    locale = prompt.locale
    if prompt.destroy
      flash[:notice] = "Prompt #{display}, #{locale} was successfully destroyed."
    else
      flash[:error] = 'Deletion of prompt failed.'
    end
    redirect_to setup_prompts_path
  end

  def edit
    @page_title = 'Modify a current prompt'
    @prompt = Prompt.find(params[:id])
    @displays = DISPLAYS
  end

  def index
    @page_title = 'Prompts'
    @prompts = Prompt.all(:order => 'locale asc')
    @integration = Integration.first
  end

  def new
    @page_title = 'Define a new prompt'
    @prompt = Prompt.new
    @displays = DISPLAYS
  end

  def update
    @prompt = Prompt.find(params[:id])
    if @prompt.update_attributes(params[:prompt])
      flash[:notice] = "Prompt #{@prompt.display}, #{@prompt.locale} was successfully updated."
    else
      flash[:error] = 'Update of prompt failed.'
    end
    redirect_to setup_prompts_path
  end

end
