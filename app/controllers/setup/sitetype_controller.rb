class Setup::SitetypeController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

#####################################################
# Sitetypes
#####################################################
  def index
    @page_title = 'List of site types'
    @sitetypes = Sitetype.all
    @count = @sitetypes.size
    @taxes = Taxrate.all
  end

  def sort
    @page_title = 'Update sort order of site types'
    @sitetypes = Sitetype.all
  end

  def resort
    pos = 1
    params[:sitetypes].each do |id|
      Sitetype.update(id, :position => pos)
      pos += 1
    end
    redirect_to sort_setup_sitetype_url
  end
      
  def new
    @page_title = 'Define a new site type'
    @sitetype = Sitetype.new
    @taxes = Taxrate.all
  end

  def create
    @sitetype = Sitetype.create!(params[:sitetype])
    Taxrate.active.each do |t|
      debug "evaluating taxrate #{t.id}"
      if params['tax'][t.name.to_sym]
        debug "in the list of params, #{t.name} is #{params['tax'][t.name.to_sym]}"
        if params['tax'][t.name.to_sym] == '1'
          debug "params #{t.name} exists and is 1"
          @sitetype.taxrates << t unless @sitetype.taxrates.exists?(t)
        elsif params['tax'][t.name.to_sym] == '0'
          debug "params #{t.name} exists and is 0"
          @sitetype.taxrates.delete(t) if @sitetype.taxrates.exists?(t)
        end
      end
    end
    flash[:notice] = "Sitetype #{@sitetype.name} was successfully created."
  rescue
    flash[:error] = 'Creation of new sitetype failed. Make sure name is unique'
  ensure
    redirect_to setup_sitetype_index_url
  end

  def edit
    @page_title = 'Modify a current site type'
    @sitetype = Sitetype.find(params[:id])
    @taxes = Taxrate.all
  end

  def update
    @sitetype = Sitetype.find(params[:id])
    Taxrate.active.each do |t|
      debug "evaluating taxrate #{t.id}"
      if params[t.name.to_sym]
        debug "in the list of params, #{t.name} is #{params[t.name.to_sym]}"
        if params[t.name.to_sym] == '1'
          debug "params #{t.name} exists and is 1"
          @sitetype.taxrates << t unless @sitetype.taxrates.exists?(t)
        elsif params[t.name.to_sym] == '0'
          debug "params #{t.name} exists and is 0"
          @sitetype.taxrates.delete(t) if @sitetype.taxrates.exists?(t)
        end
      else
        debug "could not find #{t.name} in params"
      end
    end
    if @sitetype.update_attributes(params[:sitetype])
      flash[:notice] = "Sitetype #{@sitetype.name} was successfully updated."
    else
      flash[:error] = 'Update of sitetype failed.'
    end
    redirect_to setup_sitetype_index_url
  end

  def destroy
    @sitetype = Sitetype.find(params[:id])
    @sitetype.destroy
    if @sitetype.errors.count.zero?
      flash[:notice] = "Sitetype #{@sitetype.name} was deleted"
    else
      debug @sitetype.errors.full_messages[0]
      (msg,comma,junk) = @sitetype.errors.full_messages[0].rpartition ','
      flash[:error] = msg + '. Recommend you change active to false.'
    end
    redirect_to setup_sitetype_index_url
  end

end
