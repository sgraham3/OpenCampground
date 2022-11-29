class Setup::DynamicStringsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login, :except => [:index]
  before_filter :authorize, :except => [:index]

  # caches_page :index
  # serve dynamic stylesheet with name defined
  # by filename on incoming URL parameter :name
  def sendfile
    filename = params[:name][0]
    debug "filename is #{filename}"
    if @stylefile = DynamicString.find_by_name(filename)
      debug "extension is #{File.extname(filename).downcase}"
      case File.extname(filename).downcase
      when '.css'
	# logger.debug "sending #{filename} as text/css"
	send_data(@stylefile.text, :type => "text/css", :disposition => 'inline')
      when '.jpg', '.jpeg'
	# logger.debug "sending #{filename} as image/jpeg"
	send_data(@stylefile.text, :type => "image/jpeg", :disposition => 'inline')
      when '.gif'
	# logger.debug "sending #{filename} as image/gif"
	send_data(@stylefile.text, :type => "image/gif", :disposition => 'inline')
      when '.png'
	# logger.debug "sending #{filename} as image/png"
	send_data(@stylefile.text, :type => "image/png", :disposition => 'inline')
      when '.bmp'
	# logger.debug "sending #{filename} as image/png"
	send_data(@stylefile.text, :type => "image/bmp", :disposition => 'inline')
      when '.js'
	# logger.debug "sending #{filename} as application/javascript"
	send_data(@stylefile.text, :type => "application/javascript", :disposition => 'inline')
      else
	# logger.debug "sending #{filename} as text/plain"
	send_data(@stylefile.text, :type => "text/plain", :disposition => 'inline')
      end
    else #no method/action specified
      debug "could not find #{filename}" 
      render(:nothing => true, :status => 404)
    end #if @stylefile..
  end 

  def index
    @file_list = []
    @logo = ''
    DynamicString.all.each do |d|
      @file_list << d.name
    end
    debug "file list is #{@file_list.inspect}"
    if File.exist? Rails.root.join('public','images','Logo.jpg')
      @logo = 'Logo.jpg' 
    end
    if File.exist? Rails.root.join('public','images','Logo.png')
      @logo = 'Logo.png' 
    end
    debug "logo is #{@logo}" unless @logo.empty?
  end

  def update
    if params[:upload]
      name = File.basename params[:upload].original_filename
      debug "file name is #{name}"
    else
      flash[:error]= 'No file selected, Browse for a file'
      redirect_to :setup_dynamic_strings and return
    end
    case params[:id]
    when 'file'
      # store data in db
      if (ds = DynamicString.find_by_name(name))
	ds.destroy
      end
      debug "creating #{name}"
      ds = DynamicString.create! :name => name, :text => params[:upload].read
      redirect_to :setup_dynamic_strings and return
    when 'logo'
      if name ==  'Logo.jpg'
        debug 'creating Logo.jpg'
	fn = Rails.root.join('public','images','Logo.jpg')
	f = File.new(fn, "w")
	f.syswrite(params[:upload].read)
	f.close
	debug "created #{fn}"
	fn = Rails.root.join('public','images','Logo.png')
	if File.exists? fn
	  debug "deleting #{fn}"
	  File.delete fn
	  if (ds = DynamicString.find_by_name('Logo.png'))
	    ds.destroy
	  end
	end
	flash[:notice] = "Logo file Logo.jpg uploaded"
      elsif name == 'Logo.png'
        debug 'creating Logo.png'
	fn = Rails.root.join('public','images','Logo.png')
	f = File.new(fn, "w")
	f.syswrite(params[:upload].read)
	f.close
	debug "created #{fn}"
	fn = Rails.root.join('public','images','Logo.jpg')
	if File.exists? fn
	  debug "deleting #{fn}"
	  File.delete fn
	  if (ds = DynamicString.find_by_name('Logo.jpg'))
	    ds.destroy
	  end
	end
	flash[:notice] = "Logo file Logo.png uploaded"
      else
        flash[:error] = "File #{name} not accepted.  File name must be Logo.jpg or Logo.png"
      end
      redirect_to :setup_dynamic_strings and return
    when 'local_css'
      debug "local css #{name}"
      @option.update_attribute :css, params[:upload].read
      redirect_to :setup_dynamic_strings and return
    when 'remote_css'
      debug "remote css #{name}"
      @option.update_attribute :remote_css, params[:upload].read
      redirect_to :setup_dynamic_strings and return
    else
      flash[:error] = "id #{params[:id]} not handled"
      redirect_to :setup_dynamic_strings and return
    end
  end

  def destroy
    case params[:id]
    when 'css','remote_css'
      debug 'handling css'
      @option.update_attribute params[:id].to_sym, nil
      flash[:notice] = "#{params[:id]} removed from database"
    when 'logo'
      debug 'handling logo'
      ['Logo.jpg','Logo.png'].each do |f|
	filename = Rails.root.join('public','images',f)
	debug "looking for #{f}"
	if File.exists?  filename
	  debug "file exists #{filename.basename.to_s}"
	  File.delete "#{filename}"
	  debug "destroyed #{filename.basename.to_s}"
	  flash[:notice] = "#{filename.basename.to_s} removed"
	else
	  flash[:warn] = "#{filename.basename.to_s} not found"
	end
      end
    else
      debug 'handling misc file'
      # it must be a file in the database to delete
      # restore the file to its original name
      filename = params[:id].sub(/#/,'.')
      debug "deleting #{filename}"
      ds = DynamicString.find_by_name filename
      if ds
	ds.destroy
	debug "destroyed #{filename}"
	flash[:notice] = "#{filename} removed from database"
      else
	debug "#{filename} not found in db"
	flash[:warning] = "#{filename} not found in database"
      end
    end
    redirect_to :setup_dynamic_strings
  rescue => err
    if filename.class == 'Pathname'
      flash[:error] = "error deleting #{filename.basename.to_s} #{err.to_s}"
    else
      flash[:error] = "error deleting #{filename} #{err.to_s}"
    end
    redirect_to :setup_dynamic_strings
  end
end
