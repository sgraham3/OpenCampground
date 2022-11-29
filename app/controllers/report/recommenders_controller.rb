class Report::RecommendersController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  # GET /report_recommenders/new
  # GET /report_recommenders/new.xml
  def new
    @page_title = "Recommenders Report Selection"
    @reservation = Reservation.new
    @reservation.startdate = currentDate
    @reservation.enddate = currentDate
    @recommender = Recommender.new
  end

  # POST /report_recommenders
  # POST /report_recommenders.xml
  def create
    if params[:csv]
      startdate = session[:startdate] 
      enddate = session[:enddate] 
      history = session[:history] 
      inpark = session[:inpark] 
      res = session[:res] 

      generate_recommendations(startdate, enddate, history, inpark, res)

      # headers
      csv_string = '"Source of",'
      if history == true
	csv_string << '"Historical",,'
      end
      if inpark == true
	csv_string << '"In Park",,'
      end
      if res == true
	csv_string << '"Reservations",,'
      end
      csv_string << '"Total",' + "\n"
      csv_string << '"Recommendations",'
      if history == true
	csv_string << '"Count","Days",'
      end
      if inpark == true
	csv_string << '"Count","Days",'
      end
      if res == true
	csv_string << '"Count","Days",'
      end
      csv_string << '"Count","Days"' + "\n"

      #data
      @recommends.each_key do |src|
	csv_string << "\"#{src}\","
	if history == true
	  csv_string << @recommends[src]["h_cnt"].to_s + ',' + @recommends[src]["h_days"].to_s + ','
	end
	if inpark == true
	  csv_string << @recommends[src]["i_cnt"].to_s + ',' + @recommends[src]["i_days"].to_s + ','
	end
	if res == true
	  csv_string << @recommends[src]["r_cnt"].to_s + ',' + @recommends[src]["r_days"].to_s + ','
	end
	csv_string << @recommends[src]["t_cnt"].to_s + ',' + @recommends[src]["t_days"].to_s + "\n"
      end
      
      send_data(csv_string, 
		:type => 'text/csv;charset=iso-8859-1;header=present',
		:disposition => 'attachment; filename=Recommenders.csv') if csv_string.length
    else
      @page_title = "Sources of Customer Recommendations"
      @res = Reservation.new(params[:reservation])
      startdate = @res.startdate
      enddate = @res.enddate
      if startdate == enddate
	@page_title = "Sources of Customer Recommendations for #{startdate}"
      else
	@page_title = "Sources of Customer Recommendations for #{startdate} thru #{enddate}"
      end
      @history = params[:include][:use_historical].to_i == 1?true:false
      @inpark = params[:include][:use_inpark].to_i == 1?true:false
      @res = params[:include][:use_reservations].to_i == 1?true:false

      session[:enddate] = enddate
      session[:startdate] = startdate
      session[:history] = @history
      session[:inpark] = @inpark
      session[:res] = @res

      # you have to select something
      unless @history || @inpark || @res
	flash[:error] = "You must select at least one type of data to generate a report"
	redirect_to new_report_recommender_path and return
      end
      generate_recommendations( startdate, enddate, @history, @inpark, @res)
    end
  end
private
  def generate_recommendations(startdate, enddate, history, current, future)
    # start off with a hash
    @recommends = Hash.new
    # we want to find all stays and total by recommender both days and occurances
    # for each group we have enabled
    if history == true
      hist = Archive.all(:conditions => ["close_reason rlike ? and enddate >= ? and startdate <= ?",
                                          '^checkout*', startdate, enddate],
			  :order => "recommender asc")
      hist.each do |h|
	if h.recommender == nil
	  name = 'unknown'
	else
	  name = h.recommender
	end
        unless @recommends.member?(name)
	  @recommends[name] = Hash.new
	end
	@recommends[name]["t_cnt"] = 0
	@recommends[name]["t_days"] = 0
	stdate = h.startdate < startdate ? startdate : h.startdate
	eddate = h.enddate > enddate ? enddate : h.enddate
	unless @recommends[name].member? "h_cnt"
	  @recommends[name]["h_cnt"] = 1
	else
	  @recommends[name]["h_cnt"] += 1
	end
	unless @recommends[name].member? "h_days"
	  @recommends[name]["h_days"] = eddate - stdate
	else
	  @recommends[name]["h_days"] += (eddate - stdate)
	end
      end
    end

    if current == true
      inpark = Reservation.all( :conditions => ["checked_in = ? and enddate >= ? and startdate <= ? and archived = ?",
                                                true, startdate, enddate, false],
				:include => "recommender",
				:order => "recommenders.position asc")
      inpark.each do |i|
	if i.recommender_id == 0
	  name = 'unknown'
	else
	  name = i.recommender.name
	end
        unless @recommends.member?(name)
	  @recommends[name] = Hash.new
	end
	@recommends[name]["t_cnt"] = 0
	@recommends[name]["t_days"] = 0
	stdate = i.startdate < startdate ? startdate : i.startdate
	eddate = i.enddate > enddate ? enddate : i.enddate
	unless @recommends[name].member? "i_cnt"
	  @recommends[name]["i_cnt"] = 1
	else
	  @recommends[name]["i_cnt"] += 1
	end
	unless @recommends[name].member? "i_days"
	  @recommends[name]["i_days"] = eddate - stdate
	else
	  @recommends[name]["i_days"] += (eddate - stdate)
	end
      end
    end
    
    if future == true
      res = Reservation.all( :conditions => ["confirm = ? and checked_in = ? and enddate >= ? and startdate <= ? and archived = ?",
                                             true, false, startdate, enddate, false],
			     :include => "recommender",
			     :order => "recommenders.position asc")
      res.each do |r|
	if r.recommender_id == 0
	  name = 'unknown'
	else
	  name = r.recommender.name
	end
        unless @recommends.member?(name)
	  @recommends[name] = Hash.new
	end
	@recommends[name]["t_cnt"] = 0
	@recommends[name]["t_days"] = 0
	stdate = r.startdate < startdate ? startdate : r.startdate
	eddate = r.enddate > enddate ? enddate : r.enddate
	unless @recommends[name].member? "r_cnt"
	  @recommends[name]["r_cnt"] = 1
	else
	  @recommends[name]["r_cnt"] += 1
	end
	unless @recommends[name].member? "r_days"
	  @recommends[name]["r_days"] = eddate - stdate
	else
	  @recommends[name]["r_days"] += (eddate - stdate)
	end
      end
    end
    @recommends.each_key do |src|
      if history == true
	@recommends[src]["t_cnt"] += @recommends[src]["h_cnt"] if @recommends[src].member?("h_cnt")
	@recommends[src]["t_days"] += @recommends[src]["h_days"] if @recommends[src].member?("h_days")
      end
      if current == true
	@recommends[src]["t_cnt"] += @recommends[src]["i_cnt"] if @recommends[src].member?("i_cnt")
	@recommends[src]["t_days"] += @recommends[src]["i_days"] if @recommends[src].member?("i_days")
      end
      if future == true
	@recommends[src]["t_cnt"] += @recommends[src]["r_cnt"] if @recommends[src].member?("r_cnt")
	@recommends[src]["t_days"] += @recommends[src]["r_days"] if @recommends[src].member? ("r_days")
      end
    end
  end
end
