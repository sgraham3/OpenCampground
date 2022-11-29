class AddSeasons < ActiveRecord::Migration
  def self.up
    create_table :seasons do |t|
      t.column "name", :string, :unique => true
      t.column "startdate", :date, :default => nil
      t.column "enddate", :date, :default => nil
    end
    Season.reset_column_information
    #
    # set up a default season
    #
    Season.new do |s|
      s.name = "default"
      s.startdate = Date.new(2000,1,1).to_s
      # put the end date so far in the future 
      # that it doesn't matter
      s.enddate = Date.new(2100,1,1).to_s
      s.save
    end
    #
    # move charges into the reservation database
    #
    Reservation.find(:all).each do |res|
      res.save_charges(Charge.new(res.startdate,
                                  res.enddate,
		                  res.space.price,
		                  res.discount,
				  res.id,
				  1))
      res.save
    end
    #
    # create the join table
    #
    create_table "rates" do |t|
      t.column "season_id", :integer
      t.column "price_id", :integer
      t.column "daily_rate",   :integer, :limit => 4,  :default => 0,  :null => false
      t.column "weekly_rate",  :integer, :limit => 4,  :default => 0,  :null => false
      t.column "monthly_rate", :integer, :limit => 4,  :default => 0,  :null => false
    end
    Rate.reset_column_information
    #
    # initialize the join table
    #
    # copy price info into the rate db and
    # initialize price and season ids
    #
    season=Season.find(:first)
    Price.find(:all).each do |p|
      r=Rate.new
      r.season_id = season.id
      r.price_id = p.id
      r.daily_rate = p.daily_rate
      r.weekly_rate = p.weekly_rate
      r.monthly_rate = p.monthly_rate
      r.save
    end
    #
    # we will not use the price data in the prices table now.  
    # It is all in the rates table
    #
    remove_column "prices", "daily_rate"
    remove_column "prices", "weekly_rate"
    remove_column "prices", "monthly_rate"
    Price.reset_column_information
  end

  def self.down
    #
    # put the columns back in
    #
    add_column "prices", "daily_rate",   :integer, :limit => 4,  :default => 0,  :null => false
    add_column "prices", "weekly_rate",  :integer, :limit => 4,  :default => 0,  :null => false
    add_column "prices", "monthly_rate", :integer, :limit => 4,  :default => 0,  :null => false
    Price.reset_column_information
    #
    # this gets us an array of rates each with three prices
    # copy the data into the prices table
    #
    Rate.find(:all, :conditions => "season_id = 1").each do |r|
      r.price.daily_rate = r.daily_rate
      r.price.weekly_rate = r.weekly_rate
      r.price.monthly_rate = r.monthly_rate
      r.price.save
    end
    #
    # get rid of the seasons and rates
    #
    drop_table :seasons
    drop_table :rates
  end
end
