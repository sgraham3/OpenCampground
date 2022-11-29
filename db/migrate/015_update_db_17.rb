class UpdateDb17 < ActiveRecord::Migration

  class Recommender < ActiveRecord::Base; end
  class DateFmt < ActiveRecord::Base; end

  def self.up
    add_column "options", "no_vehicles", :integer, :default => 1
    add_column "reservations", "vehicle_license_2", :string,  :limit => 20
    add_column "reservations", "vehicle_state_2",   :string,  :limit => 4
    add_column "archives", "vehicle_license_2", :string,  :limit => 20
    add_column "archives", "vehicle_state_2",   :string,  :limit => 4

    add_column "options", "no_phones",  :integer, :default => 1
    add_column "campers", "phone_2", :string, :limit => 18
    add_column "archives", "phone_2", :string, :limit => 18

    add_column "options", "lookback",  :integer, :default => 7

    add_column "options", "use_recommend", :boolean, :default => false
    create_table :recommenders do |t|
      t.string :name, :limit => 20
      t.timestamps
    end
    # add an initial placeholder recommender
    r=Recommender.new :name => 'none'
    r.save

    add_column "reservations", "recommender_id",   :integer,  :default => 0
    add_column "archives", "recommender", :string,  :limit => 20

    add_column "options", "use_seasonal", :boolean, :default => false
    add_column "options", "season_start", :date, :default => Date.today.beginning_of_year
    add_column "options", "season_end", :date, :default => Date.today.end_of_year
    add_column "rates", "seasonal_rate", :decimal, :precision => 8, :scale => 2, :default => 0.0, :null => false
    add_column "reservations", "seasonal_rate", :decimal, :precision => 8, :scale => 2, :default => 0.0
    add_column "reservations", "seasonal_charges", :decimal, :precision => 8, :scale => 2, :default => 0.0
    add_column "reservations", "seasonal", :boolean, :default => false
    add_column "archives", "seasonal", :boolean, :default => false
    add_column "taxrates", "apl_seasonal", :boolean, :default => false

    add_column "options", "print", :boolean, :default => false
    add_column "options", "use_calendar", :boolean, :default => false

    add_column "options", "date_fmt_id", :integer, :default => 1
    create_table "date_fmts" do |t|
      t.string :name, :limit => 16
      t.string :fmt, :limit => 16
    end
    [ {'name'=>'short', 'fmt' => "%b %d, %Y"},
      {'name'=>'natural', 'fmt' => "%B %d, %Y"},
      {'name'=>'iso_date', 'fmt' => "%Y-%m-%d"},
      {'name'=>'finnish', 'fmt' => "%d.%m.%Y"},
      {'name'=>'american', 'fmt' => "%m/%d/%Y"},
      {'name'=>'euro_24hr', 'fmt' => "%d %B %Y"},
      {'name'=>'euro_24hr_ymd', 'fmt' => "%Y.%m.%d"},
      {'name'=>'italian', 'fmt' => "%d/%m/%Y"} ].each do |t|
      fmt = DateFmt.new t
      fmt.save
    end

    change_column "discounts", "discount_percent", :decimal, :precision => 4, :scale => 2, :default => 0.0
    change_column "reservations", "discount_percent", :decimal, :precision => 4, :scale => 2, :default => 0.0
    begin
      Space.reset_sizes # correct error in previous version
    rescue
    end
  end

  def self.down
    remove_column "options", "no_vehicles"
    remove_column "reservations", "vehicle_license_2"
    remove_column "reservations", "vehicle_state_2"
    remove_column "archives", "vehicle_license_2"
    remove_column "archives", "vehicle_state_2"

    remove_column "options", "no_phones"
    remove_column "campers", "phone_2"
    remove_column "archives", "phone_2"

    remove_column "options", "lookback"

    remove_column "options", "use_recommend"
    remove_column "reservations", "recommender_id"
    remove_column "archives", "recommender"
    drop_table "recommenders"

    remove_column "options", "use_seasonal"
    remove_column "options", "season_start"
    remove_column "options", "season_end"
    remove_column "rates", "seasonal_rate"
    remove_column "reservations", "seasonal_rate"
    remove_column "reservations", "seasonal_charges"
    remove_column "reservations", "seasonal"
    remove_column "archives", "seasonal"
    remove_column "taxrates", "apl_seasonal"
    remove_column "options", "print"
    remove_column "options", "use_calendar"

    remove_column "options", "date_fmt_id"
    drop_table "date_fmts"
    change_column "discounts", "discount_percent", :integer, :default => 0
    change_column "reservations", "discount_percent", :integer, :default => 0

  end
end
