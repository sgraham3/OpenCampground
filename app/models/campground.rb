class Campground
# a class for things concerning the campground
  extend MyLib

  # return true if the campground is open for given reservation
  # false if not open
  ###########################################################################################################
  # requirement: the campground is open on the date the closure starts (a reservation can end that day).
  #              the campground is closed on the date the closure ends (a reservation cannot start that day).
  ###########################################################################################################
  #
  def self.open?(startdate, enddate)
    option = Option.first
    # ActiveRecord::Base.logger.debug "Campground::open? "
    #  return true unless option.use_closed == true
    # ActiveRecord::Base.logger.debug "Campground::open? use_closed is #{option.use_closed}"
    return true if option.use_closed? == false
    return false if enddate < startdate # enddate must be greater than or equal to startdate

    # ActiveRecord::Base.logger.debug "Campground::open? option.closed_start is #{option.closed_start}, option.closed_end is #{option.closed_end}"
    if option.closed_start <= option.closed_end
      # closed all in one calendar year eg. closed for summer like in AZ
      closed = Date.new(startdate.year, option.closed_start.month, option.closed_start.day)
      next_closed = Date.new(startdate.year+1, option.closed_start.month, option.closed_start.day)
      opened = Date.new(startdate.year, option.closed_end.month, option.closed_end.day)
      last_opened = Date.new(startdate.year-1, option.closed_end.month, option.closed_end.day)
      return true if enddate <= closed && startdate > last_opened
      return true if startdate > opened && enddate <= next_closed
      return false
    else
      # closure spans parts of two calendar years eg. closed for winter like in MN.
      closed = Date.new(startdate.year, option.closed_start.month, option.closed_start.day)
      opened = Date.new(startdate.year, option.closed_end.month, option.closed_end.day)
      return true if enddate <= closed && startdate > opened
      return false
    end
  end

  def self.closed?(startdate, enddate)
    !self.open?(startdate, enddate)
  end

  def self.closed_dates(start_date,end_date)
    option = Option.first

    if option.closed_start < option.closed_end
      # closed all in one calendar year eg. closed for summer like in AZ
      c_start = Date.new(start_date.year, option.closed_start.month, option.closed_start.day)
      c_end = Date.new(start_date.year, option.closed_end.month, option.closed_end.day)
    else
      # closure spans parts of two calendar years eg. closed for winter like in MN.
      c_start = Date.new(start_date.year, option.closed_start.month, option.closed_start.day)
      c_end = Date.new(start_date.year + 1, option.closed_end.month, option.closed_end.day)
    end
    return c_start, c_end, self.open?(start_date, end_date)
  end

  def self.next_open
    option = Option.first
    now = currentDate
    return now if option.use_closed? == false

    open_date = Date.new(now.year, option.closed_end.month, option.closed_end.day)+1
    if option.closed_start <= option.closed_end
      # closed all in one calendar year eg. closed for summer like in AZ
      return open_date
    else
      # closure spans parts of two calendar years eg. closed for winter like in MN.
      if now > open_date
        # next open is next year
	return open_date.change(:year => open_date.year + 1)
      else
        # next open is this year
	return open_date
      end
    end
  end
end
