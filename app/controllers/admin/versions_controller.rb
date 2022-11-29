class Admin::VersionsController < ApplicationController
  require 'net/ftp'
  require 'fileutils'
  before_filter :login_from_cookie
  before_filter :check_login
  before_filter :clear_session

  ###################################################################
  # look at the versions available and get the one with the highest
  # revision number.  Give the user the description and the option
  # to download the version with the highest revision number.
  # If up to date notify the user.
  ###################################################################
  def index
    @page_title = 'Confirm Update'
    Version.destroy_all ["install_pending = ?", true]
    login
    installed_revision = OC_VERSION # preserve the installed revision
    @revision = OC_VERSION 
    @ftp.chdir "Updates/#{OC_RELEASE}"
    info "chdir to Updates/#{OC_RELEASE} worked"
    updates = @ftp.list '*'
    updates.each do |u|
      us = u.split(' ')
      u = us[us.size - 1]
      # is this revision already installed?
      if u.to_i > @revision.to_i 
	# u is greater than current .. keep looking there might be a newer one
	info "#{u} is newer than #{@revision}"
	@revision = u
      else
	info "#{u} is older than #{@revision}"
      end
    end
    if @revision.to_i <= installed_revision.to_i
      @ftp.close
      new_updates
    else
      # fetch the description
      Dir::chdir Rails.root
      Dir::chdir 'tmp'
      @ftp.get "#{@revision}/Description"
      @desc = IO::read 'Description'
    end
    @success = true
  rescue => err
    error err.to_s
    flash[:error] = 'Error in update: ' + err.to_s
    @success = false
  ensure
    @ftp.close if @ftp
  end

  ###################################################################
  # download the specified version
  # after successfull download give user option to install
  # parameters include revision
  ###################################################################
  def edit
    @page_title = 'Install Update'
    slash = '/'
    tmp = Rails.root.join('tmp')
    if params[:maintenance]
      @maintenance = true
      revisions_to_install = Version.find_all_by_install_pending true, :order => :revision
      Dir::chdir tmp
      FileUtils::rm 'Description' # a little cleanup needed
      @files = Array.new
      @dirs = Array.new
      @deletes = Array.new
      revisions_to_install.each do |rev|
	login
	@ftp.chdir "Maintenance/#{OC_RELEASE}"
	info "chdir to Maintenance/#{OC_RELEASE} worked"
	info "fetching for #{rev.revision}"
	# iterate by directories listed
	tries = 0
	begin
	  @ftp.get rev.revision + '/Dirs'
	rescue
	  tries += 1
	  if tries < 3
	    error 'retry for get of ' + rev.revision + '/Dirs'
	    retry
	  else
	    raise
	  end
	end
	info "fetched #{rev.revision}/Dirs"
	dirstr = File::open 'Dirs'
	# for each directory listed
	while dirname = dirstr.gets 
	  dir = dirname.chomp
	  # debug "processing #{dir} and making tmp dir"
	  # create a temp dir and change to it
	  FileUtils::mkdir dir unless File.directory? dir
	  # debug "change to #{dir}"
	  FileUtils::cd dir
	  # get a list of all the files in the directory
	  tries = 0
	  begin
	    filestr = @ftp.list rev.revision + '/' + dir + '/'
	  rescue
	    tries += 1
	    if tries < 3
	      error 'retry for list ' + rev.revision + '/' + dir
	      retry
	    else
	      raise
	    end
	  end
	  # debug "got list of #{filestr.size} files"
	  # for each file in the directory
	  filestr.each do |f|
 	    # debug "processing #{f}"
	    unless f[0].chr == 'd'
	      # if not a directory get it 
	      file = (f.split(' '))[-1]
	      remote_fn = rev.revision + '/' + dir + '/' + file
	      # debug "getting #{remote_fn}"
	      tries = 0
	      begin
		@ftp.get remote_fn
	      rescue
		tries += 1
		if tries < 3
		  error 'retry for get ' + remote_fn
		  retry
		else
		  raise
		end
	      end
	      # put it on the list of files
	      @files << dir + slash + file
	    else
	      debug 'skipping directory'
	    end
	  end
	  # debug 'changing back to ' + tmp
	  Dir::chdir tmp
	  # put the directory on the list of directories
	  @dirs << dir
	end
	dirstr.close
	# get deletes
	@ftp.get rev.revision + '/Deletes'
	file = File::open 'Deletes'
	info 'fetched Deletes'
	while filename = file.gets 
	  fn = filename.chomp
	  @deletes << fn
	end
	file.close
	@ftp.close if @ftp
      end
      info 'Files downloaded'
      flash[:notice] = 'Files downloaded'
      FileUtils::rm 'Dirs' if File.exists? 'Dirs' # a little cleanup needed
      FileUtils::rm 'Files' if File.exists? 'Files' # a little cleanup needed
      FileUtils::rm 'Deletes' if File.exists? 'Deletes' # a little cleanup needed
      # we now have @files containing all of the files in all of
      # the updates and @dirs containing all of the directories 
      # in all of the updates
      @files.sort!
      @files.uniq!
      @dirs.sort!
      @dirs.uniq!
      @deletes.sort!
      @deletes.uniq!
      dirs = File.new('Dirs', 'w+')
      dirs.puts @dirs
      dirs.close
      files = File.new('Files', 'w+')
      files.puts @files
      files.close
      deletes = File.new('Deletes', 'w+')
      deletes.puts @deletes
      deletes.close
      @success = true
    else
      login
      @revision = params[:revision]
      @ftp.chdir "Updates/#{OC_RELEASE}/#{@revision}"
      info "chdir to Updates/#{OC_RELEASE}/#{@revision} worked"
      Dir::chdir Rails.root
      Dir::chdir 'tmp'
      FileUtils::rm 'Description' # a little cleanup needed
      # need to create directories if needed
      @ftp.get 'Dirs'
      file = File::open 'Dirs'
      info 'fetched Dirs'
      while dirname = file.gets 
	dir = dirname.chomp
	FileUtils::mkdir dir unless File.exists? dir
      end
      # get files
      @ftp.get 'Files'
      file = File::open 'Files'
      info 'fetched Files'
      while filename = file.gets 
	fn = filename.chomp
	@ftp.get fn
	# copy the files
	FileUtils::cp((File::basename fn), fn)
	FileUtils::rm File::basename fn
      end
      info 'Files downloaded'
      flash[:notice] = 'Files downloaded'
      @success = true
    end
  rescue => err
    error err.to_s
    flash[:error] = 'Problem downloading files: ' + err.to_s
    @success = false
  ensure
    @ftp.close if @ftp
  end

  ###################################################################
  # install the specified version
  # after successfull install notify user
  ###################################################################
  def update
    @page_title = 'Update Complete'
    @revision = params[:revision]
    @windows = @os == "Windows_NT"

    # make directories
    Dir::chdir Rails.root
    Dir::chdir 'tmp'
    file = File::open 'Dirs'
    info 'creating dirs'
    while dirname = file.gets
      dir = Rails.root.join(dirname.chomp)
      FileUtils::mkdir dir unless File.exists? dir
    end
    file.close

    # install files
    file = File::open 'Files'
    info 'copying files'
    while fn = file.gets
      src = Rails.root.join('tmp',fn.chomp)
      dst = Rails.root.join(fn.chomp)
      # save file to old version
      FileUtils::mv(dst, "#{dst}.bak") if File::exists? dst
      # copy the files
      FileUtils::cp(src, dst)
      FileUtils::rm src
    end
    file.close

    # delete files
    begin
      file = File::open 'Deletes'
      info 'deleting files'
      while fn = file.gets
        begin
	  dst = Rails.root.join(fn.chomp)
	  FileUtils::rm_r(dst) if File::exists? dst
	rescue => err
	  error 'delete ' + err.to_s
	end
      end
    rescue => err
      error 'delete ' + err.to_s
    ensure
      file.close
    end

    info 'files installed'
    if params[:maintenance]
      completed = Version.find_all_by_install_pending true
      rev = "Updates for Open Campground version #{OC_RELEASE}, revision(s)"
      completed.each do |c|
	info c.revision
        rev += " #{c.revision} "
	c.update_attribute :install_pending, false
      end
      rev += 'installed.'
      flash[:notice] = rev
      restart
    else
      flash[:notice] = "Updates for Open Campground version #{OC_RELEASE}, revision #{OC_VERSION} installed.  Restart Open Campground"
    end
    FileUtils::rm 'Files'
    FileUtils::rm 'Dirs'
  rescue => err
    flash[:error] = 'Problem installing files: ' + err.to_s
    error err.to_s
  end

  ###################################################################

private
  def new_updates
  # TO DO
  # need to limit to production because version is in db

    login
    # clean out db of partially completed updates
    installed_revision = OC_VERSION # preserve the installed revision
    @ftp.chdir "Maintenance/#{OC_RELEASE}"
    info "chdir to Maintenance/#{OC_RELEASE} worked"
    updates = @ftp.list '*'
    revisions_to_install = Array.new
    updates.each do |u|
      us = u.split(' ')
      u = us[us.size - 1]
      info u
      # is this revision already installed?
      if u.to_i > installed_revision.to_i
	info "#{u} is greater than #{installed_revision}" 
	unless (vers = Version.find_by_release_and_revision(OC_RELEASE, u))
	  # u is uninstalled.  Add to list to be installed
	  info "#{u} is not installed yet"
	  revisions_to_install << u
	else
	  info "#{u} is in the database"
	end
      end
    end
    if revisions_to_install.empty?
      flash[:notice] = "No new updates for Open Campground available" 
      redirect_to :controller => :admin and return
    else
      Dir::chdir Rails.root
      Dir::chdir 'tmp'
      # fetch the descriptions
      @desc = ''
      revisions_to_install.each do |r|
	info "fetching #{r}/Description"
	@ftp.get "#{r}/Description"
	desc = IO::read 'Description'
	@desc += desc
	Version.create! :release => OC_RELEASE, :revision => r, :description => desc
      end
    end
    @success = true
    @maintenance = true
  rescue => err
    error err.to_s
    flash[:error] = 'Error in update: ' + err.to_s
    @success = false
  ensure
    @ftp.close if @ftp
  end

  def login
    if Rails.env.development?
      server = 'ocsrv.net'
      debug 'connecting to pc-server'
    else
      server = @option.ftp_server ? @option.ftp_server : 'ocsrv.net'
    end
    account = @option.ftp_account ? @option.ftp_account : 'anonymous'
    passwd = @option.ftp_passwd ? @option.ftp_passwd : 'opencampground'
    @ftp = Net::FTP::new server, account, passwd
    @ftp.passive = true
    info "login to #{server} worked"
    @windows = @os == "Windows_NT"
  end

end
