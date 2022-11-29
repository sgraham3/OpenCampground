class Admin::UserManualController < ApplicationController

  def index
    fn = Rails.root.join('doc','UserManual.pdf')
    fn2 = Rails.root.join('doc','User Manual.pdf')
    if File.exist? fn
      send_file fn, :disposition => 'inline'
    elsif File.exist? fn2
      send_file fn2, :disposition => 'inline'
    else
      flash[:error] = "Cannot find User Manual"
      redirect_to :action => :index
    end
  end

end
