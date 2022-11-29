class Initial < ActiveRecord::Migration

  class Creditcard < ActiveRecord::Base; end
  class Discount < ActiveRecord::Base; end
  class Rigtype < ActiveRecord::Base; end
  class Sitetype < ActiveRecord::Base; end

  def self.up

    create_table "archives", :force => true  do |t|
      t.column "name",            :string,  :limit => 32,  :default => "", :null => false
      t.column "address",         :string,  :limit => 32
      t.column "city",            :string,  :limit => 32
      t.column "state",           :string,  :limit => 4
      t.column "mail_code",       :string,  :limit => 12
      t.column "adults",          :integer, :limit => 2,   :default => 2
      t.column "pets",            :integer, :limit => 2,   :default => 0
      t.column "kids",            :integer, :limit => 2,   :default => 0
      t.column "discount_name",   :string,  :limit => 24
      t.column "startdate",       :date
      t.column "enddate",         :date
      t.column "deposit",         :integer
      t.column "total_charge",    :integer
      t.column "special_request", :string
      t.column "slides",          :integer, :limit => 1,   :default => 0
      t.column "length",          :integer, :limit => 3
      t.column "rig_age",         :integer, :limit => 3
      t.column "vehicle_license", :string,  :limit => 20
      t.column "vehicle_state",   :string,  :limit => 4
      t.column "rigtype_name",    :string,  :limit => 12,  :default => ""
      t.column "space_name",      :string,  :limit => 24,  :default => ""
      t.column "group_name",      :string,  :limit => 24
      t.column "close_reason",    :string,  :limit => 128
    end

    create_table "campers", :force => true do |t|
      t.column "last_name",    :string,  :limit => 16, :default => "", :null => false
      t.column "first_name",   :string,  :limit => 16, :default => "", :null => false
      t.column "address",      :string,  :limit => 32, :default => "", :null => false
      t.column "city",         :string,  :limit => 32, :default => "", :null => false
      t.column "state",        :string,  :limit => 4,  :default => "", :null => false
      t.column "mail_code",    :string,  :limit => 12, :default => "", :null => false
      t.column "activity",     :date
      t.column "lock_version", :integer,               :default => 0
    end

    create_table "creditcards", :force => true do |t|
      t.column "name", :string, :limit => 12, :default => "", :null => false
    end

    cash = Creditcard.create(:name => 'cash')
    cash.save

    create_table "discounts", :force => true do |t|
      t.column "name",             :string,  :limit => 24, :default => "",    :null => false
      t.column "discount_percent", :integer,               :default => 0
      t.column "disc_appl_month",  :boolean,               :default => false
      t.column "disc_appl_week",   :boolean,               :default => false
    end

    create_table "groups", :force => true do |t|
      t.column "name",            :string,  :limit => 24, :default => "", :null => false
      t.column "expected_number", :integer,               :default => 0,  :null => false
      t.column "startdate",       :date
      t.column "enddate",         :date
      t.column "camper_id",       :integer
    end

    create_table "prices", :force => true do |t|
      t.column "name",         :string,  :limit => 24, :default => "", :null => false
      t.column "daily_rate",   :integer, :limit => 4,  :default => 0,  :null => false
      t.column "weekly_rate",  :integer, :limit => 4,  :default => 0,  :null => false
      t.column "monthly_rate", :integer, :limit => 4,  :default => 0,  :null => false
    end

    create_table "reservations", :force => true do |t|
      t.column "camper_id",       :integer,               :default => 0,     :null => false
      t.column "rigtype_id",      :integer, :limit => 3,  :default => 0,     :null => false
      t.column "space_id",        :integer,               :default => 0,     :null => false
      t.column "discount_id",     :integer
      t.column "group_id",        :integer
      t.column "creditcard_id",   :integer,               :default => 0
      t.column "startdate",       :date,                                     :null => false
      t.column "enddate",         :date,                                     :null => false
      t.column "deposit",         :integer,               :default => 0
      t.column "total_charge",    :integer,               :default => 0
      t.column "special_request", :string
      t.column "slides",          :integer, :limit => 1,  :default => 0
      t.column "length",          :integer, :limit => 3,  :default => 0
      t.column "rig_age",         :integer, :limit => 3,  :default => 0
      t.column "vehicle_license", :string,  :limit => 20
      t.column "vehicle_state",   :string,  :limit => 4
      t.column "checked_in",      :boolean,               :default => false
      t.column "adults",          :integer, :limit => 2,  :default => 2
      t.column "pets",            :integer, :limit => 2,  :default => 0
      t.column "kids",            :integer, :limit => 2,  :default => 0
      t.column "credit_card_no",  :integer, :limit => 20, :default => 0
      t.column "expdate",         :date
      t.column "lock_version",    :integer,               :default => 0
    end

    create_table "rigtypes", :force => true do |t|
      t.column "name", :string, :limit => 12, :default => "", :null => false
    end

    other = Rigtype.create(:name => 'other')
    other.save

    create_table "sitetypes", :force => true do |t|
      t.column "name", :string, :limit => 12, :default => "", :null => false
    end

    create_table "spaces", :force => true do |t|
      t.column "name",              :string,  :limit => 24, :default => "",    :null => false
      t.column "power_15a",         :boolean,               :default => false
      t.column "power_30a",         :boolean,               :default => false
      t.column "power_50a",         :boolean,               :default => false
      t.column "water",             :boolean,               :default => false
      t.column "sewer",             :boolean,               :default => false
      t.column "length",            :integer, :limit => 3,  :default => 0,     :null => false
      t.column "width",             :integer, :limit => 3,  :default => 102
      t.column "sitetype_id",       :integer, :limit => 3,  :default => 0,     :null => false
      t.column "price_id",          :integer, :limit => 3,  :default => 0,     :null => false
      t.column "special_condition", :string
      t.column "unavailable",       :boolean,               :default => false
    end

    create_table "taxes", :force => true do |t|
      t.column "room_tax_percent",  :float,                :default => 0.0
      t.column "sales_tax_percent", :float,                :default => 0.0
      t.column "local_tax_percent", :float,                :default => 0.0
      t.column "room_tax_amount",   :integer, :limit => 6, :default => 0
      t.column "rmt_apl_week",      :boolean,              :default => false
      t.column "rmt_apl_month",     :boolean,              :default => false
      t.column "st_apl_week",       :boolean,              :default => true
      t.column "st_apl_month",      :boolean,              :default => true
    end

    initial_tax = Tax.create
    initial_tax.save

  end

  def self.down
    drop_table :archives
    drop_table :campers
    drop_table :creditcards
    drop_table :discounts
    drop_table :groups
    drop_table :prices
    drop_table :reservations
    drop_table :rigtypes
    drop_table :sitetypes
    drop_table :spaces
    drop_table :taxes
  end

end
