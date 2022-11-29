class Setup::CampersController < ApplicationController
  require 'camper'
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :authorize

  # GET /setup_campers/new
  # GET /setup_campers/new.xml
  def new
    @camper = Camper.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @camper }
    end
  end

  # POST /setup_campers
  # POST /setup_campers.xml
  def create
    debug
    warning = 'Campers created except:'
    error_count = 0
    unless params[:upload]
      debug 'no params[:upload]'
      flash[:error]= 'No Filename specified. Select a .csv file'
      raise
    end
    name = uploadFile params[:upload]
    debug "uploaded #{name}"
    # name =  params[:upload]
    # name = sanitize_filename name
    # debug "filename is #{params[:upload].name}"
    # debug "filename is #{params[:upload]}"
    # read from name.csv and write to campers db
    csv_file = File.open(name, "rb")
    debug "csv file #{name} opened"
    # get the first line
    line = csv_file.gets
    debug "have line #{line}"
    line.chomp!
    keys = line.split(',')
    debug "keys are #{keys.inspect}"
    attributes = Camper.column_names
    unless keys.member?("last_name")
      flash[:error] = 'last_name column is required but not included'
      redirect_to new_setup_camper_url and return
    end
    error_list = ''
    keys.each do |k|
      unless attributes.member?(k)
	error_list += "#{k} is not a valid column name\n" unless k == 'country'
      end
    end
    unless error_list.empty?
      flash[:error] = error_list
      redirect_to new_setup_camper_url and return
    end
    while (line = csv_file.gets)
      line.chomp!
      hash = {}
      lineSplit = line.split(',')
      lineSplit.each_index do |x|
	if keys[x] == 'country'
	  country_id = Country.find_or_create_by_name(lineSplit[x]).id
	  hash["country_id".to_sym] = country_id
	else
	  hash[keys[x].to_sym] = lineSplit[x]
	end
      end
      begin
	stat = Camper.create! hash
      rescue
	warning += "create failed for #{hash.inspect}\n"
	error_count += 1
      end
      raise if error_count > 10
    end
    if warning
      flash[:warning] = warning unless warning.empty?
    else
      flash[:notice] = "File upload succeeded"
    end
    File.delete name
  rescue
    debug 'upload failed'
    if error_count > 10
      flash[:error] = 'excess errors, you have probably not entered a manditory field'
    else
      flash[:error] = "File upload failed.  Did you select a file to upload?"
    end
  ensure
    redirect_to new_setup_camper_url and return
  end
private
  def uploadFile filename
    name =  filename.original_filename
    name = sanitize_filename name
    directory = "tmp"
    # create the file path
    path = File.join(directory, name)
    debug path
    if File::exist? path
      return path
    end
    # write the file
    if File.open(path, "wb") { |f| f.write(params[:upload].read) }
      # flash[:notice] = "File upload succeeded"
    else
      flash[:error] = "File upload failed"
    end
    return path
  rescue => err
    flash[:error] = "File upload failed.  Did you select a file to upload?"
    error err.to_s
  end

end
