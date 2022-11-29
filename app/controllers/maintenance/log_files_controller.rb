class Maintenance::LogFilesController < ApplicationController
  require 'fileutils'
  before_filter :login_from_cookie
  before_filter :check_login

  def index
    @page_title = "Manage Log Files"
    Dir::chdir Rails.root
    handle_files "log", "log*"
    Dir::chdir Rails.root
    session[:next_action] = :manage_logs
  end 

  def show
    file_list = session[:file_list]
    id = params[:id].to_i
    send_file "log/#{file_list[id]}", :filename => file_list[id], :type => "text/plain"
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
    redirect_to maintenance_log_files_path
  end

end

