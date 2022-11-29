class Maintenance::ConflictsController < ApplicationController
  # GET /maintenance_conflicts
  # GET /maintenance_conflicts.xml
  def index
    @page_title = 'List of Reservations in Conflict'
    @conflicts = Conflict::double_booking

    if @conflicts.size == 0
      flash[:notice] = 'No reservation conflicts found'
      redirect_to maintenance_index_path and return
    else
      session[:conflicts] = @conflicts
      respond_to do |format|
	format.html # index.html.erb
	format.xml  { render :xml => @maintenance_conflicts }
      end
    end
  end

  # GET /maintenance_conflicts/1
  # GET /maintenance_conflicts/1.xml
  def show
    @page_title = 'Reservations in Conflict'
    # need to specify this
    id = params[:id].to_i
    c = session[:conflicts]
    conflicts = c[id]
    first = c[id]["first"]
    second = c[id]["second"]
    @first = Reservation.find (first)
    @second = Reservation.find (second)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @conflict }
    end
  end
end
