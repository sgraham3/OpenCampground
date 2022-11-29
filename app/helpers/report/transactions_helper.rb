module Report::TransactionsHelper
  def get_table
    startdate = session[:startdate]
    enddate = session[:enddate]
    discounts = Discount.count :conditions => ["active = ?",true]
    recommendations = @option.use_recommend?
    tbl_str = String.new
    tbl_str << '<table>'
    tbl_str << '<tr><th>Reservation</th><th>Space</th><th>Camper</th><th>Start date</th><th>End date</th>'
    tbl_str << '<th>Discount</th>' if discounts > 0
    tbl_str << '<th>Recommender</th>' if recommendations
    tbl_str << "<th>Description</th></tr>\n"
    if @new_res.size > 0
      tbl_str << "<tr><td colspan=\"2\"><b>#{@new_res.size} new reservations</b></td></tr>"
      @new_res.each do |res|
	st_ = res.startdate.strftime("%m/%d/%Y")
	end_ = res.enddate.strftime("%m/%d/%Y")
	tbl_str << "<tr><td>#{res.id}</td><td>#{res.space.name}</td><td>#{res.camper.full_name}</td><td>#{st_}</td><td>#{end_}</td>"
	tbl_str << (res.discount_id > 0 ? "<td>#{res.discount.name}</td>" : '<td></td>') if discounts > 0
	tbl_str << (res.recommender_id > 0 ? "<td>#{res.recommender.name}</td>" : '<td></td>') if recommendations
	tbl_str << "<td>#{res.last_log_entry('reservation')}</td></tr>\n"
      end
    end
    if @checkins.size > 0
      tbl_str << "<tr><td colspan=\"2\"><b>#{@checkins.size} checkins</b></td></tr>"
      @checkins.each do |res|
	st_ = res.startdate.strftime("%m/%d/%Y")
	end_ = res.enddate.strftime("%m/%d/%Y")
	tbl_str << "<tr><td>#{res.id}</td><td>#{res.space.name}</td><td>#{res.camper.full_name}</td><td>#{st_}</td><td>#{end_}</td>"
	tbl_str << (res.discount_id > 0 ? "<td>#{res.discount.name}</td>" : '<td></td>') if discounts > 0
	tbl_str << (res.recommender_id > 0 ? "<td>#{res.recommender.name}</td>" : '<td></td>') if recommendations
	tbl_str << "<td>#{res.last_log_entry('checkin')}</td></tr>\n"
      end
    end
    if @checkouts.size > 0
      tbl_str << "<tr><td colspan=\"2\"><b>#{@checkouts.size} checkouts</b></td></tr>"
      @checkouts.each do |res|
	st_ = res.startdate.strftime("%m/%d/%Y")
	end_ = res.enddate.strftime("%m/%d/%Y")
	tbl_str << "<tr><td>#{res.id}</td><td>#{res.space.name}</td><td>#{res.camper.full_name}</td><td>#{st_}</td><td>#{end_}</td>"
	tbl_str << (res.discount_id > 0 ? "<td>#{res.discount.name}</td>" : '<td></td>') if discounts > 0
	tbl_str << (res.recommender_id > 0 ? "<td>#{res.recommender.name}</td>" : '<td></td>') if recommendations
	tbl_str << "<td>#{res.last_log_entry('checkout')}</td></tr>\n"
      end
    end
    if @cancels.size > 0
      tbl_str << "<tr><td colspan=\"2\"><b>#{@cancels.size} cancellations</b></td></tr>"
      @cancels.each do |res|
	st_ = res.startdate.strftime("%m/%d/%Y")
	end_ = res.enddate.strftime("%m/%d/%Y")
	tbl_str << "<tr><td>#{res.id}</td><td>#{res.space.name}</td><td>#{res.camper.full_name}</td><td>#{st_}</td><td>#{end_}</td>"
	tbl_str << (res.discount_id > 0 ? "<td>#{res.discount.name}</td>" : '<td></td>') if discounts > 0
	tbl_str << (res.recommender_id > 0 ? "<td>#{res.recommender.name}</td>" : '<td></td>') if recommendations
	tbl_str << "<td>#{res.last_log_entry('cancelled')}</td></tr>\n"
      end
    end
    if @changes.size > 0
      tbl_str << "<tr><td colspan=\"2\"><b>#{@changes.size} changes</b></td></tr>"
      @changes.each do |res|
	st_ = res.startdate.strftime("%m/%d/%Y")
	end_ = res.enddate.strftime("%m/%d/%Y")
	change_array = res.all_log_entries('changed')
	change_array.each do |c|
	  tbl_str << "<tr><td>#{res.id}</td><td>#{res.space.name}</td><td>#{res.camper.full_name}</td><td>#{st_}</td><td>#{end_ }</td>"
	  tbl_str << (res.discount_id > 0 ? "<td>#{res.discount.name}</td>" : '<td></td>') if discounts > 0
	  tbl_str << (res.recommender_id > 0 ? "<td>#{res.recommender.name}</td>" : '<td></td>') if recommendations
	  tbl_str << "<td>#{c}</td></tr>\n"
	end
      end
    end
    tbl_str << '</table>'
    tbl_str 
  end
end
