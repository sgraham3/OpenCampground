class BogusController < ApplicationController

  def index
  end

  def handle_bogus
    str = ''
    params[:anything].each do |p|
      str += p + ' '
    end
    info 'from ' + request.remote_ip + ' params => /' +  str
    render :nothing => true
  end

end
