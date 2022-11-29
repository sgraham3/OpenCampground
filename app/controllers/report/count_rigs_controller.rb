class Report::CountRigsController < ApplicationController
  before_filter :login_from_cookie
  before_filter :check_login

  # GET /report_count_rigs/new
  # GET /report_count_rigs/new.xml
  def new
    @page_title = "Rig Count Setup"
  end

  # POST /report_count_rigs
  # POST /report_count_rigs.xml
  def create
    @page_title = "Rig Count"

    sort1 = params[:Sorts][:sort1]
    sort2 = params[:Sorts][:sort2]
    sort3 = params[:Sorts][:sort3]
    sort = case sort1
           when 'site type' then "sitetypes.name"
           when 'space name' then "spaces.position"
           when 'end date' then "enddate"
           when 'start date' then "startdate"
           when 'none' 
             sort2 = 'none'
             sort3 = 'none'
	     ""
           end
    sort += case sort2
            when 'site type' then sort1 == 'site type' ? "" :  ", sitetypes.name"
            when 'space name' then sort1 == 'space name' ? "" : ", spaces.position"
            when 'end date' then sort1 == 'end date' ? "" : ", enddate"
            when 'start date' then sort1 == 'start date' ? "" : ", startdate"
            when 'none' 
	      sort3 = 'none' 
	      ""
            end
    sort += case sort3
            when 'site type' then (sort1 == 'site type' || sort2 == 'site type') ? "" : ", sitetypes.name" 
            when 'space name' then (sort1 == 'space name' || sort2 == 'space name') ? "" : ", spaces.position" 
            when 'end date' then (sort1 == 'end date' || sort2 == 'end date') ? "" : ", enddate" 
            when 'start date' then (sort1 == 'start date' || sort2 == 'start date') ? "" : ", startdate" 
	    else
	      ""
            end
    if sort.size > 0
      sort += " asc"
      sorts = sort1 + sort2 + sort3
      if sorts.include?('site type')
	@reservations = Reservation.all( :conditions =>  ["confirm = ? and checked_in = ? and archived = ?",
                                                          true, true, false],
					 :include => { :space => :sitetype },
					 :order => sort)
      elsif sorts.include?('space name')
	@reservations = Reservation.all( :conditions =>  ["confirm = ? and checked_in = ? and archived = ?",
                                                          true, true, false],
					 :include =>  :space,
					 :order => sort)
      else
	@reservations = Reservation.all( :conditions =>  ["confirm = ? and checked_in = ? and archived = ?",
                                                          true, true, false],
					 :order => sort)
      end
    else
      @reservations = Reservation.all( :conditions =>  ["confirm = ? and checked_in = ? and archived = ?",
                                                        true, true, false])
    end
  end
end
