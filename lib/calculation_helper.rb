module CalculationHelper

  # calculate days, weeks, months based on week or month are to be used
  def days_weeks_months( start_dt, end_dt, disc_week, disc_month )
    # ActiveRecord::Base.logger.debug "CalculationHelper#days_weeks_months: start_dt = #{start_dt}, end_dt = #{end_dt}, disc_week = #{disc_week}, disc_month = #{disc_month}"
    # dates are Date objects
    # see how many days are in the interval
    # if we discount weeks or months we will compute by weeks
    # and months otherwise we will compute by days
    #
    weeks = 0
    months = 0
    days = end_dt - start_dt

    if disc_month
      # if we span a new year or so add 12 months for each year
      if end_dt.year > start_dt.year
        end_month = end_dt.month + (end_dt.year - start_dt.year) * 12
      else
        end_month = end_dt.month
      end
      # get the raw number of months
      months = end_month - start_dt.month
      
      # if the st and en days are the same the stay is even months
      if end_dt.day == start_dt.day
	days = 0
	# ActiveRecord::Base.logger.debug "CalculationHelper#days_weeks_months: even months = #{months}"
        return [days, weeks, months]
      elsif (start_dt.at_end_of_month == start_dt) && (end_dt.at_end_of_month == end_dt)
	days = 0
	# ActiveRecord::Base.logger.debug "CalculationHelper#days_weeks_months: start and end at_end_of_month months = #{months}"
        return [days, weeks, months]
      end
      # we have a number of whole months plus a residual
      # if the end day is less than the start day subtract a month
      months -= 1 if end_dt.day < start_dt.day

      # now we need to figure out how many days there are from the end of 
      # the whole months to the end date

      # advance the start date by the number of whole months
      adj_start_dt = start_dt>>months

      days = end_dt - adj_start_dt
    end

    if disc_week
      weeks = (days / 7).to_i
      days = (days % 7).to_i
    end
    return [days.to_i, weeks.to_i, months.to_i]
  end

end
