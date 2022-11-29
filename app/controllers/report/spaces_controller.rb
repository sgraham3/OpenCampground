class Report::SpacesController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  # GET /report_spaces
  # GET /report_spaces.xml
  def index
    @page_title = "Space Summary"
    @occupied = Hash.new
    @spaces = Space.all
    @reservations = Reservation.all( :conditions =>  ["confirm = ? AND checked_in = ? AND checked_out = ? AND cancelled = ?",
                                                      true, true, false, false], :include => 'space')
    @reservations.each do |res|
      @occupied[res.space.name] = res.id
    end
  end

  # PUT /report_spaces/1
  # PUT /report_spaces/1.xml
  def update
    if params[:change] == 'release' 
      Space.update(params[:id].to_i, :unavailable => 0)
    else
      Space.update(params[:id].to_i, :unavailable => 1)
    end
    redirect_to :action => :index
  end
end
