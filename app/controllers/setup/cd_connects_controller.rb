class Setup::CdConnectsController < ApplicationController

# may need some error checking/handling here

  # GET /setup_cd_connects/1/edit
  def edit
    @cd_connect = CdConnect.create unless @cd_connect = CdConnect.first
  end

  # PUT /setup_cd_connects/1
  # PUT /setup_cd_connects/1.xml
  def update
    @cd_connect = CdConnect.first
    if @cd_connect.update_attributes params[:cd_connect]
      debug 'updates ok'
      flash[:notice] = 'Updated'
    else
      debug 'error in updates'
      flash[:error] =  'error in updates'
    end
    redirect_to :action => "edit"
  end

end
