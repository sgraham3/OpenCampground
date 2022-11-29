class Maintenance::BackupController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  def index
    # generate the filename
    fn_dt = currentTime.strftime("%Y%m%d%H%M")+'.bak'
    filename = Rails.root.join('backup',fn_dt)
    debug "doing backup to #{filename}"
    # get the config variables
    db_config = ActiveRecord::Base.configurations[Rails.env]
    username = db_config['username'] 
    password =  db_config['password'] ? "-p"+db_config['password'].to_s : ""
    database = db_config['database']
    case db_config['adapter']
    when 'mysql', 'mysql2'
      if @os == "Windows_NT"
        result = system "..\\..\\mysql\\bin\\mysqldump -u #{username} #{password} -r #{filename} #{database}"
      else
        result = system "mysqldump -u #{username} #{password} -r #{filename} #{database}"
      end
      if result
	flash[:notice] = "Backup successful, go to <i>Admin->Maintenance->Manage Backup Files</i> to download #{fn_dt} for secure storage"
      else
	flash[:error] = "Error in Backup, Backup failed"
	error "Backup failed with status #{$?}"
      end
    when 'sqlite3'
      if @os == "Windows_NT"
	flash[:error] = "Unable to backup databases of type: #{db_config['adapter']} on Windows"
      else
        result = system "sqlite3 #{database} .dump > #{filename}"
      end
      if result
	flash[:notice] = "Backup successful, go to <i>Admin->Maintenance->Manage Backup Files</i> to download it for secure storage"
      else
	flash[:error] = "Error in Backup, Backup failed"
	error "Backup failed with status #{$?}"
      end
    else
      flash[:error] = "Unable to backup databases of type: #{db_config['adapter']}"
    end
  rescue => err
    flash[:error] = "Error in Backup, Backup failed (#{err})"
    error "Backup failed, err = #{err}"
  ensure
    redirect_to root_url
  end
 
end
