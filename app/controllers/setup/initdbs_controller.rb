class Setup::InitdbsController < ApplicationController

  # curl localhost:3000/setup/initdb/initdemo
  # GET initdemo_setup_initdb_path
  # initialize a training or demo system
  def initdemo
    if Rails.env.production?
      # this is only designed for a demo or training system
      info 'production system redirecting to reservation/list'
      redirect_to :controller => setup_index_path and return
    else
      info 'demo/training system, redoing db'
      ############################################
      # db reset replaces db from schema and seeds
      ############################################
      Rake::Task["db:reset"].reenable
      Rake::Task["db:reset"].invoke
      debug 'reset done'
      Rake::Task["db:load_db_from_fixtures"].reenable
      Rake::Task["db:load_db_from_fixtures"].invoke
      debug 'load done'
      # reread the options.
      @option = Option.first
      # get rid of the login info because everything
      # may have changed
      session[:user_id] = nil
      # need to calculate charges on all reservations
      Reservation.all.each do |res|
        Charges.new(res.startdate,
                    res.enddate,
                    res.space.price.id,
                    res.discount.id,
                    res.id,
                    res.seasonal)
        charges = Charge.stay(res.id)
        total = 0.0
        charges.each { |c| total += c.amount - c.discount }
        total += calculate_extras(res.id)
        total -= res.onetime_discount
        tax_amount = Taxrate.calculate_tax(res.id, @option)
        debug "total #{total}, tax_amount #{tax_amount}, res_id #{res.id}"
        res.update_attributes :total => total, :tax_amount => tax_amount
      end
      debug 'redirecting'
      redirect_to :controller => '/reservation', :action => 'list'
    end
  rescue StandardError => e
    logger.error "error in Initdb:initdemo #{e}"
    flash[:error] = "Application error"
    redirect_to :controller => '/reservation', :action => 'list'
  end
end
