class VariableChargesController < ApplicationController
  # GET /variable_charges
  # GET /variable_charges.xml
  def index
    vc = VariableCharge.all :order => 'reservation_id'
    @taxes = Taxrate.active
    if vc.size == 0
      flash[:notice] = "No variable charges have been made"
      redirect_to maintenance_index_path and return
    end
    @variable_charges = vc.paginate :page => params[:page], :per_page => @option.disp_rows

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @variable_charges }
    end
  end

  # GET /variable_charges/1
  # GET /variable_charges/1.xml
  def show
    vc = VariableCharge.find_all_by_reservation_id(params[:id])
    @taxes = Taxrate.active
    @variable_charges = vc.paginate :page => params[:page], :per_page => @option.disp_rows
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @variable_charge }
    end
  end

  # GET /variable_charges/new
  # GET /variable_charges/new.xml
  def new
    @variable_charge = VariableCharge.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @variable_charge }
    end
  end

  # GET /variable_charges/1/edit
  def edit
    @variable_charge = VariableCharge.find(params[:id])
  end

  # POST /variable_charges
  # POST /variable_charges.xml
  def create
    @variable_charge = VariableCharge.new(params[:variable_charge])

    respond_to do |format|
      if @variable_charge.save
        format.html { redirect_to(@variable_charge, :notice => 'VariableCharge was successfully created.') }
        format.xml  { render :xml => @variable_charge, :status => :created, :location => @variable_charge }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @variable_charge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /variable_charges/1
  # PUT /variable_charges/1.xml
  def update
    @variable_charge = VariableCharge.find(params[:id])

    respond_to do |format|
      if params[:taxes]
        params[:taxes].each do |t|
	  tax = Taxrate.find_by_name t[0]
	  # t is the key
	  if t[1] == '1'
	    @variable_charge.taxrates << tax unless @variable_charge.taxrates.exists?(tax)
	  else
	    @variable_charge.taxrates.delete(tax) if @variable_charge.taxrates.exists?(tax)
	  end
	end
      end
      if @variable_charge.update_attributes(params[:variable_charge]) || params[:taxes]
        format.html { redirect_to(variable_charges_path, :notice => 'VariableCharge was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @variable_charge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /variable_charges/1
  # DELETE /variable_charges/1.xml
  def destroy
    @variable_charge = VariableCharge.find(params[:id])
    @variable_charge.destroy

    respond_to do |format|
      format.html { redirect_to(variable_charges_url) }
      format.xml  { head :ok }
    end
  end
end
