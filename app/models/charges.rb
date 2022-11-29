# a class for computing and passing charges
class Charges
  include CalculationHelper
  include MyLib

  # DAY = 0
  # WEEK = 1
  # MONTH = 2
  # SEASON = 3

  ###################################################################
  # a class method to compute the charges and create charge objects
  ###################################################################

  def initialize(cc_start_dt = Date.new(2006, 10, 23), cc_end_dt = Date.new(2007, 1, 15), price_id = 1, discount_id = 1, res_id = 0, full_season = false, storage = false)
    option = Option.first
    disc = Discount.find(discount_id)
    @days_in_stay = 0

    # get the price for the default season
    pc = Rate.find_current_rate(1, price_id)
    ActiveRecord::Base.logger.debug "Rate id is #{pc.id} rate for season 1, price #{price_id} is daily #{pc.daily_rate.to_f}, weekly #{pc.weekly_rate.to_f}, monthly #{pc.monthly_rate.to_f}, seasonal #{pc.seasonal_rate.to_f}, storage #{pc.monthly_storage.to_f}"

    # delete all old records
    Charge.destroy_all(["reservation_id = ?", res_id])

    if full_season
      # calculate charge from rate
      ActiveRecord::Base.logger.debug 'full season'
      # create and save entry
      amount = pc.seasonal_rate
      charge = Charge.create(:reservation_id => res_id,
                             :rate => pc.seasonal_rate,
                             :period => cc_end_dt - cc_start_dt,
                             :start_date => cc_start_dt,
                             :end_date => cc_end_dt,
                             :amount => amount,
                             :discount => disc.charge(amount, Charge::SEASON, cc_start_dt),
                             :charge_units => Charge::SEASON)
    elsif storage
      ActiveRecord::Base.logger.debug 'storage'
      days, weeks, months = days_weeks_months(cc_start_dt, cc_end_dt - 1.day, true, true)
      ActiveRecord::Base.logger.debug "days = #{days}, weeks = #{weeks}, months = #{months}"
      months += 1 if (days > 0) || (weeks > 0)
      end_date = cc_start_dt + months.months
      if Season.one_storage_rate(price_id)
        # single storage rate
        ActiveRecord::Base.logger.debug 'single storage rate'
        amount = pc.monthly_storage * months
        ActiveRecord::Base.logger.debug "storage for #{months} months"
        charge = Charge.create(:reservation_id => res_id,
                               :rate => pc.monthly_storage,
                               :period => months,
                               :start_date => cc_start_dt,
                               :end_date => end_date,
                               :amount => amount,
                               :discount => disc.charge(amount, Charge::STORAGE, cc_start_dt),
                               :charge_units => Charge::STORAGE)
      else
        # multiple storage rates
        ActiveRecord::Base.logger.debug 'multiple storage rates'
        # we will iterate over the days changing rates with seasons
        current_date = cc_start_dt
        current_month = cc_start_dt.month
        current_season = Season.find_by_date(current_date)
        days_in_month = current_date.end_of_month - current_date.beginning_of_month + 1
        days_stored = 0
        charges = []
        ActiveRecord::Base.logger.debug "start = #{cc_start_dt}, end = #{end_date} season = #{current_season.name}, current_date = #{current_date}"
        while current_date <= end_date # discount one day at a time
          if (current_season == Season.find_by_date(current_date)) && (current_month == current_date.month) && (current_date != end_date)
            days_stored += 1
            ActiveRecord::Base.logger.debug "days_in_stay = #{days_stored}, nothing else changed"
          else
            ActiveRecord::Base.logger.debug "season = #{current_season.name}, current_date = #{current_date} days_in_stay = #{days_stored}, something changed"
            period = days_stored / days_in_month
            rate = Rate.find_current_rate(current_season.id, price_id).monthly_storage
            amount = rate * period
            charges << Charge.new(:reservation_id => res_id,
                                  :season_id => current_season.id,
                                  :start_date => current_date - days_stored,
                                  :end_date => current_date,
                                  :period => period,
                                  :rate => rate,
                                  :amount => amount,
                                  :discount => disc.charge(amount, Charge::STORAGE, cc_start_dt),
                                  :charge_units => Charge::STORAGE)
            current_season = Season.find_monthly_by_date(current_date)
            days_in_month = current_date.end_of_month - current_date.beginning_of_month + 1
            ActiveRecord::Base.logger.debug "days in new month = #{days_in_month}"
            current_month = current_date.month
            days_stored = 1
          end
          current_date = current_date.succ
        end
        # need to combine identical members of charges array
        ActiveRecord::Base.logger.debug "(before) count of charges = #{charges.size}"
        output = []
        charge = charges.shift
        charges.each do |ch|
          charge.combine ch
        rescue RuntimeError => e
          case e.to_s
          when 'different_season', 'different_rate'
            output << charge
            charge = ch
          else
            raise
          end
        end
        output << charge
        ActiveRecord::Base.logger.debug "(after) count of charges = #{output.size}"
        # write out all of the records
        output.each { |o| o.save }
      end
    else # all of the rest
      ################################################################
      # calculate days, weeks and months for space charges
      ################################################################
      @days, @weeks, @months = days_weeks_months(cc_start_dt, cc_end_dt,
                                                 Rate.find_current_rate(Season.find_weekly_by_date(cc_start_dt).id, price_id).weekly_rate > 0.0,
                                                 Rate.find_current_rate(Season.find_monthly_by_date(cc_start_dt).id, price_id).monthly_rate > 0.0)

      ActiveRecord::Base.logger.debug "days = #{@days}, weeks = #{@weeks}, months = #{@months}"
      current_date = cc_start_dt
      season_count = Season.count(:conditions => ["active = ?", true])
      if season_count == 1
        ActiveRecord::Base.logger.debug "Only one season"
        season = Season.find_monthly_by_date(current_date)
        pc = Rate.find_current_rate(season.id, price_id)
        ActiveRecord::Base.logger.debug "calculating months"
        amount = pc.monthly_rate * @months
        end_date = current_date + @months.months
        if @months > 0
          charge = Charge.create(:reservation_id => res_id,
                                 :season_id => season.id,
                                 :start_date => current_date,
                                 :end_date => end_date,
                                 :period => @months,
                                 :rate => pc.monthly_rate,
                                 :amount => amount,
                                 :discount => disc.charge(amount, Charge::MONTH, current_date, @months),
                                 :charge_units => Charge::MONTH)
        end
        ActiveRecord::Base.logger.debug "calculating weeks"
        current_date = end_date
        end_date = current_date + (@weeks * 7)
        season = Season.find_weekly_by_date(current_date)
        amount = pc.weekly_rate * @weeks
        if @weeks > 0
          charge = Charge.create(:reservation_id => res_id,
                                 :season_id => season.id,
                                 :start_date => current_date,
                                 :end_date => end_date,
                                 :period => @weeks,
                                 :rate => pc.weekly_rate,
                                 :amount => amount,
                                 :discount => disc.charge(amount, Charge::WEEK, current_date, @weeks),
                                 :charge_units => Charge::WEEK)
        end
        current_date = end_date
        end_date = current_date + @days
        season = Season.find_by_date(current_date)
        ActiveRecord::Base.logger.debug "calculating days"
        if option.variable_rates?
          ActiveRecord::Base.logger.debug "using variable rates"
          charges = []
          while current_date <= end_date
            amount = pc.rate_for_day(current_date, option.variable_rates)
            ActiveRecord::Base.logger.debug "rate for #{current_date} is #{amount}"
            charges << Charge.new(:reservation_id => res_id,
                                  :season_id => season.id,
                                  :start_date => current_date,
                                  :end_date => current_date + 1,
                                  :period => 1,
                                  :rate => amount,
                                  :amount => amount,
                                  :discount => disc.charge(amount, Charge::DAY, current_date, 1),
                                  :charge_units => Charge::DAY)
            current_date = current_date.succ
          end
          output = []
          charge = charges.shift
          charges.each do |ch|
            charge.combine ch
          rescue RuntimeError => e
            case e.to_s
            when 'different_season', 'different_rate'
              output << charge
              charge = ch
            else
              raise
            end
          end
          output << charge
          output.each { |c| c.save }
        else
          ActiveRecord::Base.logger.debug "not using variable rates"
          amount = pc.daily_rate * @days
          if @days > 0
            charge = Charge.create(:reservation_id => res_id,
                                   :season_id => season.id,
                                   :start_date => current_date,
                                   :end_date => end_date,
                                   :period => @days,
                                   :rate => pc.daily_rate,
                                   :amount => amount,
                                   :discount => disc.charge(amount, Charge::DAY, current_date, @days),
                                   :charge_units => Charge::DAY)
          end
        end
      else # multiple seasons
        ActiveRecord::Base.logger.debug "#{season_count} seasons"
        ######################################################################
        # calculate for months
        ######################################################################
        if @months > 0
          ActiveRecord::Base.logger.debug 'monthly'
          month_charges = []
          # find starting season that applies to this date (monthly rates only)
          season = Season.find_monthly_by_date(cc_start_dt)
          months_end = current_date + @months.months
          month = current_date.month
          days_in_month = current_date.end_of_month - current_date.beginning_of_month + 1
          @days_in_stay = 0
          ActiveRecord::Base.logger.debug "days in month = #{days_in_month}"
          ActiveRecord::Base.logger.debug "season = #{season.name}, current_date = #{current_date}, month = #{month}, months_end = #{months_end}"
          while current_date < months_end
            ActiveRecord::Base.logger.debug "date is #{current_date}"
            if (season == Season.find_monthly_by_date(current_date)) &&
               (month == current_date.month)
              @days_in_stay += 1
              ActiveRecord::Base.logger.debug "days_in_stay = #{@days_in_stay}, nothing else changed"
            else
              ActiveRecord::Base.logger.debug "days_in_stay = #{@days_in_stay}, something changed"
              period = @days_in_stay / days_in_month
              rate = Rate.find_current_rate(season.id, price_id).monthly_rate
              amount = rate * period
              month_charges << Charge.new(:reservation_id => res_id,
                                          :season_id => season.id,
                                          :start_date => current_date - @days_in_stay.days,
                                          :end_date => current_date,
                                          :period => period,
                                          :rate => rate,
                                          :amount => amount,
                                          :discount => disc.charge(amount, Charge::MONTH, current_date),
                                          :charge_units => Charge::MONTH)
              season = Season.find_monthly_by_date(current_date)
              days_in_month = current_date.end_of_month - current_date.beginning_of_month + 1
              ActiveRecord::Base.logger.debug "days in new month = #{days_in_month}"
              month = current_date.month
              @days_in_stay = 1
            end
            current_date = current_date.succ
          end

          if @days_in_stay > 0
            period = @days_in_stay / days_in_month
            rate = Rate.find_current_rate(season.id, price_id).monthly_rate
            amount = rate * period
            month_charges << Charge.new(:reservation_id => res_id,
                                        :season_id => season.id,
                                        :start_date => current_date - @days_in_stay.days,
                                        :end_date => current_date,
                                        :period => period,
                                        :rate => rate,
                                        :amount => amount,
                                        :discount => disc.charge(amount, Charge::MONTH, current_date),
                                        :charge_units => Charge::MONTH)
          end
          ActiveRecord::Base.logger.debug "(before) count of charges = #{month_charges.size}"
          output = []
          charge = month_charges.shift
          month_charges.each do |ch|
            charge.combine ch
          rescue RuntimeError => e
            case e.to_s
            when 'different_season', 'different_rate'
              output << charge
              charge = ch
            else
              raise
            end
          end
          output << charge
          ActiveRecord::Base.logger.debug "(after) count of charges = #{output.size}"

          if output.size > 1
            tot = 0.0
            output.each { |c| tot += c.period }
            dif = @months.to_f - tot
            ActiveRecord::Base.logger.debug "dif = #{dif}"
            output.at(-1).period += dif
            output.at(-1).amount += output.at(-1).rate * dif
            output.at(-1).discount = disc.charge(output.at(-1).amount, Charge::MONTH, dif) # how to handle?
          end

          output.each do |m|
            m.discount = disc.charge(m.amount, Charge::MONTH, currentDate, m.period) # how to handle?
            m.save
          end
        end

        ######################################################################
        # calculate for weeks
        ######################################################################
        @days_in_stay = 0
        # find starting season that applies to this date (weekly rates only)
        season = Season.find_weekly_by_date current_date
        # iterate through days in weeks
        ActiveRecord::Base.logger.debug "Months #{@months}, Weeks #{@weeks}, Days #{@days}"
        (@weeks * 7).times do
          new_season = Season.find_weekly_by_date current_date
          # if the season id changed
          if new_season.id != season.id
            # calculate the weekly charge for this season and save
            if @days_in_stay > 0
              # get the price for this season
              pc = Rate.find_current_rate(season.id, price_id)
              period = @days_in_stay.to_f / 7.0
              amount = pc.weekly_rate * period
              # p "weeks days_in_stay = #{@days_in_stay}"
              charge = Charge.create(:reservation_id => res_id,
                                     :season_id => season.id,
                                     :start_date => current_date - @days_in_stay.days,
                                     :end_date => current_date,
                                     :period => period,
                                     :rate => pc.weekly_rate,
                                     :amount => amount,
                                     :discount => disc.charge(amount, Charge::WEEK, currentDate, period),
                                     :charge_units => Charge::WEEK)
              @days_in_stay = 1
            end
            season = new_season
          else
            @days_in_stay += 1
          end
          current_date = current_date.succ
        end
        # catch what is left at the end
        if @days_in_stay > 0
          ActiveRecord::Base.logger.debug "weeks overflow days_in_stay = #{@days_in_stay}"
          pc = Rate.find_current_rate(season.id, price_id)
          period = @days_in_stay.to_f / 7.0
          amount = pc.weekly_rate * period
          charge = Charge.create(:reservation_id => res_id,
                                 :season_id => season.id,
                                 :start_date => current_date - @days_in_stay.days,
                                 :end_date => current_date,
                                 :period => period,
                                 :rate => pc.weekly_rate,
                                 :amount => amount,
                                 :discount => disc.charge(amount, Charge::WEEK, currentDate, period),
                                 :charge_units => Charge::WEEK)
        end

        ######################################################################
        # calculate for days
        ######################################################################
        charges = []
        if @days > 0
          ActiveRecord::Base.logger.debug "calculating for #{@days} days"
          end_date = current_date + @days
          pc = Rate.find_current_rate(season.id, price_id)
          while current_date < end_date
            ActiveRecord::Base.logger.debug "calculating for #{current_date} "
            season = Season.find_by_date(current_date)
            pc = Rate.find_current_rate(season.id, price_id)
            daily_amount = pc.rate_for_day(current_date, option.variable_rates)
            charges << Charge.new(:reservation_id => res_id,
                                  :season_id => season.id,
                                  :start_date => current_date,
                                  :end_date => current_date + 1.days,
                                  :period => 1,
                                  :rate => daily_amount,
                                  :amount => daily_amount,
                                  :discount => disc.charge(daily_amount, Charge::DAY, current_date),
                                  :charge_units => Charge::DAY)
            current_date = current_date.succ
          end # while current_date < end_date
          output = []
          charge = charges.shift
          charges.each do |ch|
            charge.combine ch
          rescue RuntimeError => e
            case e.to_s
            when 'different_season', 'different_rate'
              output << charge
              charge = ch
            else
              raise
            end
          end
          output << charge
          output.each { |c| c.save }
        end # if @days
      end # if multiple seasons
    end # if full season reservation
  end

  def self.days(startdate, enddate, space_id)
    ActiveRecord::Base.logger.debug "dates are #{startdate} to #{enddate}"
    option = Option.first
    current_date = startdate
    daily_amount = 0.0
    price_id = Space.find(space_id).price.id
    ActiveRecord::Base.logger.debug "price_id is #{price_id}"
    while current_date < enddate
      ActiveRecord::Base.logger.debug "calculating for #{current_date} "
      season = Season.find_by_date(current_date)
      ActiveRecord::Base.logger.debug "season is #{season.name}"
      pc = Rate.find_current_rate(season.id, price_id)
      ActiveRecord::Base.logger.debug "rate is #{pc.id}"
      daily_amount += pc.rate_for_day(current_date, option.variable_rates)
      ActiveRecord::Base.logger.debug "amount is #{daily_amount}"
      current_date = current_date.succ
    end # while current_date < end_date
    ActiveRecord::Base.logger.debug "final amount is #{daily_amount}"
    daily_amount
  end
end
