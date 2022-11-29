class Setup::ExtraController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

#####################################################
# Extras
#####################################################
  def index
    @page_title = 'Extra Charges'
    @extras = Extra.all
    @taxes = Taxrate.all
    @col = @option.use_remote_reservations? ? '2' : '1'
  end

  def sort
    @page_title = 'Update sort order of extras'
    @extras = Extra.all
  end

  def resort
    pos = 1
    params[:extras].each do |id|
      Extra.update(id, :position => pos)
      pos += 1
    end
    redirect_to sort_setup_extra_url
  end
      
  def new
    @page_title = 'Add new extra charge'
    @extra = Extra.new
    @taxes = Taxrate.all
    @extra.id = -1
  end

  def create
    @extra = Extra.create!(params[:extra])
    Taxrate.active.each do |t|
      debug "evaluating taxrate #{t.id}"
      if params['tax'][t.name]
        debug "in the list of params, #{t.name} is #{params['tax'][t.name]}"
        if params['tax'][t.name] == '1'
          debug "params #{t.name} exists and is 1"
          @extra.taxrates << t unless @extra.taxrates.exists?(t)
        elsif params['tax'][t.name] == '0'
          debug "params #{t.name} exists and is 0"
          @extra.taxrates.delete(t) if @extra.taxrates.exists?(t)
        end
      end
    end
    flash[:notice] = "Extra charge #{@extra.name} was successfully created."
  rescue
    flash[:error] = "Creation of #{params[:extra][:name]} failed. Make sure name is unique"
  ensure
    redirect_to setup_extra_index_url
  end

  def edit
    @page_type = 'Edit extras'
    @extra = Extra.find(params[:id])
    @taxes = Taxrate.all
  end

  def update
    @extra = Extra.find params[:id]
    debug "found #{@extra.name}"
    Taxrate.active.each do |t|
      debug "evaluating taxrate #{t.id}"
      if params['tax'][t.name]
        debug "in the list of params, #{t.name} is #{params['tax'][t.name]}"
        if params['tax'][t.name] == '1'
	  debug "params #{t.name} exists and is 1"
	  @extra.taxrates << t unless @extra.taxrates.exists?(t)
	elsif params['tax'][t.name] == '0'
	  debug "params #{t.name} exists and is 0"
	  @extra.taxrates.delete(t) if @extra.taxrates.exists?(t)
	end
      else
        debug "could not find ['tax'][#{t.name}] in params"
      end
    end
    if @extra.update_attributes params[:extra]
      flash[:notice] = "Extra charge #{@extra.name} was successfully updated."
    else
      flash[:error] = "Update of #{@extra.name} failed."
    end
    redirect_to setup_extra_index_url
  end

  def destroy
    extra = Extra.find(params[:id])
    name = extra.name
    ext = ExtraCharge.find_all_by_extra_id(extra.id)
    if ext.size == 0
      if extra.destroy
        flash[:notice] = "Extra charge #{name} was successfully deleted."
      else
        flash[:error] = "Deletion of #{name} failed."
      end
    else
      flash[:error] = "Extra charge #{name} in use by reservations: "
      ext.each do |e|
        flash[:error] += e.reservation_id.to_s + ' '
      end
    end 
    redirect_to setup_extra_index_url
  end

  def update_type
    if params[:id].to_i > 0
      @extra = Extra.find params[:id]
      @extra.update_attributes :extra_type => params[:extra_type]
    else
      @extra = Extra.new :extra_type => params[:extra_type]
    end
    # debug @extra.inspect
    render :update do |page|
      page.replace_html('extras', :partial => 'update_type')
    end
  end
end
