class AddCharges < ActiveRecord::Migration

  class Discount < ActiveRecord::Base;end

  def self.up
    rename_column :reservations, :taxes, :tax_amount
    create_table :charges do |t|
      t.integer :reservation_id
      t.integer :season_id, :default => 1
      t.date :start_date
      t.date :end_date
      t.float :period
      t.decimal :rate, :precision => 8, :scale => 2, :default => 0.0
      t.decimal :amount, :precision => 8, :scale => 2, :default => 0.0
      t.decimal :discount, :precision => 8, :scale => 2, :default => 0.0
      t.integer :charge_units
      t.boolean :temp, :default => false
    end
    drop_table :taxes
    create_table "taxes", :force => true do |t|
      t.integer :reservation_id
      t.string :name
      t.string :rate
      t.integer :count, :default => 0
      t.decimal :amount, :precision => 6, :scale => 2
    end
    add_column :seasons, :applies_to_weekly, :boolean, :default => true
    add_column :seasons, :applies_to_monthly, :boolean, :default => true
    add_column :discounts, :disc_appl_seasonal, :boolean, :default => false
    add_column :discounts, :disc_appl_daily, :boolean, :default => true
    add_column :discounts, :amount, :decimal, :precision => 8, :scale => 2, :default => 0.0
    add_column :emails, :update_subject, :string, :default => 'Reservation Update'
    add_column :taxrates, :apl_daily, :boolean, :default => true
    add_column :options, :use_checkout_time, :boolean, :default => false
    add_column :options, :checkout_time, :time
    add_column :payments, :memo, :string

    Discount.create!(:name => 'none') unless Discount.find_by_name 'none'

    MailTemplate.create!(:name => "reservation_update", :body => "Dear {{camper}},\n\nYour reservation at My RV Park has been updated.  You are now scheduled to arrive on {{start}} and depart on {{departure}}.  We have assigned you site {{space_name}}.  The total charges are estimated at {{charges}}.  Your reservation confirmation number is {{number}}.\n\nWe look forward to serving you\nTy Coon\nManager")

    @reservations = Reservation.find :all
    @reservations.each do |res|
      say "Converting reservation #{res.id}"
      season = Season.first(:conditions=>["startdate <= ? and enddate >= ?", res.startdate, res.startdate], :order => 'startdate DESC')
      Charge.destroy_all(["reservation_id = ?", res.id])
      if res.seasonal?
	charge = Charge.create(:reservation_id => res.id,
			       :season_id => season.id,
			       :start_date => res.startdate,
			       :end_date => res.enddate,
			       :period => res.enddate - res.startdate,
			       :rate => res.seasonal_rate,
			       :amount => res.seasonal_charges,
			       :charge_units => Charge::SEASON)
      else
	charge = Charge.create(:reservation_id => res.id,
			       :season_id => season.id,
			       :start_date => res.startdate,
			       :end_date => res.enddate,
			       :period => res.months,
			       :rate => res.monthly_rate,
			       :amount => res.month_charges,
			       :discount => res.monthly_disc,
			       :charge_units => Charge::MONTH) if res.months > 0
	charge = Charge.create(:reservation_id => res.id,
			       :season_id => season.id,
			       :start_date => res.startdate,
			       :end_date => res.enddate,
			       :period => res.weeks,
			       :rate => res.weekly_rate,
			       :amount => res.week_charges,
			       :discount => res.weekly_disc,
			       :charge_units => Charge::WEEK) if res.weeks > 0
	charge = Charge.create(:reservation_id => res.id,
			       :season_id => season.id,
			       :start_date => res.startdate,
			       :end_date => res.enddate,
			       :period => res.days,
			       :rate => res.daily_rate,
			       :amount => res.day_charges,
			       :discount => res.daily_disc,
			       :charge_units => Charge::DAY) if res.days > 0
      end
    end
    add_index :charges, :start_date
    add_index :charges, :reservation_id
  end

  def self.down
    drop_table :taxes
    create_table "taxes", :force => true do |t|
      t.integer :reservation_id
      t.string :name
      t.string :rate
      t.integer :count, :default => 0
      t.decimal :amount, :precision => 6, :scale => 2
    end
    remove_column :options, :locale
    rename_column :reservations, :tax_amount, :taxes
    remove_index :charges, :start_date
    remove_index :charges, :reservation_id
    drop_table :charges
    remove_column :seasons, :applies_to_weekly
    remove_column :seasons, :applies_to_monthly
    remove_column :discounts, :disc_appl_seasonal
    remove_column :discounts, :disc_appl_daily
    remove_column :discounts, :amount
    remove_column :emails, :update_subject
    remove_column :taxrates, :apl_daily
    remove_column :options, :use_checkout_time
    remove_column :options, :checkout_time
    remove_column :payments, :memo
  end
end

