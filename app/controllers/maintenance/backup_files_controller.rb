class Maintenance::BackupFilesController < ApplicationController
  require 'fileutils'
  before_filter :login_from_cookie
  before_filter :check_login

  def index
    @page_title = "Manage Backup Files"
    Dir::chdir Rails.root
    handle_files "backup", "bak"
    Dir::chdir Rails.root
  end

  def create
    unless params[:upload]
      flash[:error] = 'File must be selected for upload'
      redirect_to maintenance_backup_files_path and return
    end
    name =  params[:upload].original_filename
    name = sanitize_filename name
    directory = "backup"
    # create the file path
    path = File.join(directory, name)
    if File::exist? path
      flash[:error] = "File already exists.  Delete the current file if you want to replace it"
    else
      # write the file
      if File.open(path, "wb") { |f| f.write(params[:upload].read) }
        flash[:notice] = "File upload succeeded"
      else
        flash[:error] = "File upload failed"
      end
    end
  rescue => err
    flash[:error] = "File upload failed.  Did you select a file to upload?"
    error err.to_s
  ensure
    session[:file_list] = nil
    redirect_to maintenance_backup_files_path
  end
  
  def show
    file_list = session[:file_list]
    id = params[:id].to_i
    send_file "backup/#{file_list[id]}", :filename => file_list[id], :type => "application/bak"
  end

  def destroy
    # get the file name
    file_list = session[:file_list]
    id = params[:id].to_i
    debug params[:id]
    debug file_list.inspect
    if @os == "Windows_NT"
      fqfn = session[:dir].gsub("/","\x5c") + file_list[id]
    else
      fqfn = session[:dir] + file_list[id]
    end
    # delete the indicated file
    result = File::delete(fqfn)
    if result
      flash[:notice] = "#{fqfn} deleted"
      debug "#{fqfn} deleted"
    else
      flash[:error] = "#{fqfn} deletion failed"
      error "#{fqfn} deletion failed"
    end
    session[:file_list] = nil
    # go back for more
    redirect_to maintenance_backup_files_path
  end

  def update
    @page_title = "Restore Complete"
    # get the config variables
    db_config = ActiveRecord::Base.configurations[Rails.env]
    username = db_config['username'] 
    password =  db_config['password'] ? "-p"+db_config['password'].to_s : ""
    database = db_config['database']
    # get the file name
    file_list = session[:file_list]
    id = params[:id].to_i
    debug params[:id] 
    session[:file_list] = nil
    case db_config['adapter']
    when 'mysql', 'mysql2'
      if @os == "Windows_NT"
        debug 'windows nt'
        backupfile = "backup\\" + file_list[id]
        Rake::Task['db:drop'].execute
        Rake::Task['db:create'].execute
        result = system "..\\..\\mysql\\bin\\mysql -u #{username} #{password} -q -e \"source #{backupfile}\" #{database}"
        if result
          Rake::Task['db:migrate'].execute
          flash[:notice] = 'Restore successful '
          restart(false)
        else
          flash[:error] = "Error in Restore, Restore failed"
          error "Restore failed with status #{$?}"
        end
      else
        debug @os
        backupfile = "backup/" + file_list[id]
        Rake::Task['db:drop'].execute
        Rake::Task['db:create'].execute
        result = system "mysql -u #{username} #{password} -q -e \"source #{backupfile}\" #{database}"
        if result
          Rake::Task['db:migrate'].execute
          flash[:notice] = 'Restore successful '
          restart(false)
        else
          flash[:error] = "Error in Restore, Restore failed"
          error "Restore failed with status #{$?}"
        end
      end
    when 'sqlite3'
      # untested
      if @os == "Windows_NT"
        flash[:error] = "Unable to restore databases of type: #{db_config['adapter']} on Windows"
      else
        Rake::Task['db:drop'].invoke
        Rake::Task['db:create'].invoke
        backupfile = "backup/" + file_list[id]
        result = system "sqlite3 #{database} < #{backupfile}"
        if result
          Rake::Task['db:migrate'].invoke
          restart(false)
        else
          flash[:error] = "Error in Restore, Restore failed"
          error "Restore failed with status #{$?}"
        end
      end
    else
      flash[:error] = "Unable to restore databases of type: #{db_config['adapter']}"
    end
    # because the user tables may not match current facts, 
    # do a defacto logout
    session[:user_id] = nil
    session[:file_list] = nil
    redirect_to maintenance_backup_files_path
  end

end

