# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 108) do

  create_table "archives", :force => true do |t|
    t.string  "name",              :limit => 66,  :default => "",    :null => false
    t.string  "address",           :limit => 32
    t.string  "city",              :limit => 32
    t.string  "state",             :limit => 16
    t.string  "mail_code",         :limit => 12
    t.integer "adults",            :limit => 2,   :default => 2
    t.integer "pets",              :limit => 2,   :default => 0
    t.integer "kids",              :limit => 2,   :default => 0
    t.string  "discount_name",     :limit => 32,  :default => ""
    t.date    "startdate"
    t.date    "enddate"
    t.decimal "deposit",                          :default => 0.0
    t.decimal "total_charge",                     :default => 0.0
    t.text    "special_request"
    t.integer "slides",            :limit => 1,   :default => 0
    t.integer "length",            :limit => 3
    t.integer "rig_age",           :limit => 3
    t.string  "vehicle_license",   :limit => 20
    t.string  "vehicle_state",     :limit => 16
    t.string  "rigtype_name",      :limit => 32,  :default => ""
    t.string  "space_name",        :limit => 32,  :default => ""
    t.string  "group_name",        :limit => 32
    t.string  "close_reason",      :limit => 128
    t.string  "phone",             :limit => 18
    t.string  "email",             :limit => 128
    t.string  "country",           :limit => 32
    t.date    "canceled"
    t.text    "extras",            :limit => 255
    t.text    "tax_str"
    t.string  "idnumber",          :limit => 24
    t.text    "log"
    t.string  "vehicle_license_2", :limit => 20
    t.string  "vehicle_state_2",   :limit => 16
    t.string  "phone_2",           :limit => 18
    t.string  "recommender",       :limit => 32
    t.boolean "seasonal",                         :default => false
    t.integer "reservation_id",                   :default => 0
    t.boolean "selected",                         :default => false
    t.string  "address2",          :limit => 32
    t.text    "payments"
  end

  create_table "blackouts", :force => true do |t|
    t.string   "name",       :limit => 32
    t.date     "startdate"
    t.date     "enddate"
    t.boolean  "active",                   :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campers", :force => true do |t|
    t.string  "last_name",    :limit => 32,  :default => "", :null => false
    t.string  "first_name",   :limit => 32,  :default => "", :null => false
    t.string  "address",      :limit => 32,  :default => "", :null => false
    t.string  "city",         :limit => 32,  :default => "", :null => false
    t.string  "state",        :limit => 16,  :default => "", :null => false
    t.string  "mail_code",    :limit => 12,  :default => "", :null => false
    t.date    "activity"
    t.integer "lock_version",                :default => 0
    t.string  "phone",        :limit => 18
    t.string  "email",        :limit => 128
    t.string  "idnumber",     :limit => 24
    t.integer "country_id",                  :default => 0
    t.string  "phone_2",      :limit => 18
    t.string  "address2",     :limit => 32
    t.text    "notes"
    t.text    "addl"
  end

  add_index "campers", ["last_name"], :name => "index_campers_on_last_name"

  create_table "card_transactions", :force => true do |t|
    t.string   "account"
    t.string   "expiry"
    t.decimal  "amount",                       :precision => 12, :scale => 2, :default => 0.0
    t.string   "currency",                                                    :default => "USD"
    t.string   "retref"
    t.integer  "reservation_id"
    t.string   "authcode"
    t.string   "avsresp"
    t.string   "batchid"
    t.string   "cvvresp"
    t.string   "name"
    t.string   "respproc"
    t.string   "resptext"
    t.string   "respcode"
    t.string   "respstat"
    t.string   "signature"
    t.string   "token"
    t.string   "accttype"
    t.string   "address"
    t.string   "city"
    t.string   "region"
    t.string   "country"
    t.string   "postal"
    t.string   "ecomind"
    t.string   "track"
    t.string   "tokenize"
    t.string   "mytoken"
    t.integer  "payment_id"
    t.boolean  "card_present"
    t.string   "session_key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "process_mode"
    t.string   "cvv2",                                                        :default => ""
    t.string   "orderid",        :limit => 20
    t.string   "bintype",        :limit => 20
    t.string   "entrymode",      :limit => 25
    t.string   "commcard",       :limit => 2
    t.text     "emv"
    t.text     "emvTagData"
    t.text     "receiptData"
  end

  add_index "card_transactions", ["reservation_id"], :name => "index_card_transactions_on_reservation_id"

  create_table "charges", :force => true do |t|
    t.integer "reservation_id"
    t.integer "season_id",                                    :default => 1
    t.date    "start_date"
    t.date    "end_date"
    t.float   "period"
    t.decimal "rate",           :precision => 8, :scale => 2, :default => 0.0
    t.decimal "amount",         :precision => 8, :scale => 2, :default => 0.0
    t.decimal "discount",       :precision => 8, :scale => 2, :default => 0.0
    t.integer "charge_units"
    t.boolean "temp",                                         :default => false
  end

  add_index "charges", ["reservation_id"], :name => "index_charges_on_reservation_id"
  add_index "charges", ["start_date"], :name => "index_charges_on_start_date"

  create_table "ck_transactions", :force => true do |t|
    t.boolean  "receiptData",                                    :default => false
    t.integer  "process_mode"
    t.string   "token"
    t.decimal  "amount",          :precision => 12, :scale => 2, :default => 0.0
    t.string   "currency",                                       :default => "USD"
    t.integer  "reservation_id"
    t.string   "month"
    t.string   "year"
    t.string   "card_brand"
    t.string   "action"
    t.string   "result"
    t.string   "status"
    t.string   "error"
    t.string   "authcode"
    t.string   "retref"
    t.string   "batchid"
    t.string   "avscode"
    t.string   "avsresp"
    t.string   "cvvcode"
    t.string   "cvvtext"
    t.string   "respcode"
    t.string   "resptext"
    t.string   "masked_card_num"
    t.integer  "payment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ck_transactions", ["reservation_id"], :name => "index_ck_transactions_on_reservation_id"

  create_table "colors", :force => true do |t|
    t.string "name"
    t.string "value"
  end

  create_table "countries", :force => true do |t|
    t.string   "name",       :limit => 32
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.boolean  "active",                   :default => true
  end

  add_index "countries", ["position"], :name => "index_countries_on_position"

  create_table "creditcards", :force => true do |t|
    t.string  "name",                :limit => 32, :default => "",    :null => false
    t.boolean "is_credit_card",                    :default => true
    t.boolean "validate_cc_number",                :default => false
    t.boolean "use_expiration",                    :default => false
    t.boolean "validate_expiration",               :default => false
    t.integer "position"
    t.boolean "active",                            :default => true
  end

  add_index "creditcards", ["position"], :name => "index_creditcards_on_position"

  create_table "discounts", :force => true do |t|
    t.string  "name",               :limit => 32,                                :default => "",    :null => false
    t.decimal "discount_percent",                 :precision => 5,  :scale => 2, :default => 0.0
    t.boolean "disc_appl_month",                                                 :default => false
    t.boolean "disc_appl_week",                                                  :default => false
    t.boolean "disc_appl_seasonal",                                              :default => false
    t.boolean "disc_appl_daily",                                                 :default => true
    t.decimal "amount",                           :precision => 8,  :scale => 2, :default => 0.0
    t.decimal "amount_daily",                     :precision => 11, :scale => 5, :default => 0.0
    t.decimal "amount_weekly",                    :precision => 11, :scale => 5, :default => 0.0
    t.decimal "amount_monthly",                   :precision => 12, :scale => 5, :default => 0.0
    t.integer "position"
    t.boolean "active",                                                          :default => true
    t.integer "duration",                                                        :default => 0
    t.integer "duration_units",                                                  :default => 1
    t.integer "delay",                                                           :default => 0
    t.integer "delay_units",                                                     :default => 1
    t.boolean "sunday",                                                          :default => true
    t.boolean "monday",                                                          :default => true
    t.boolean "tuesday",                                                         :default => true
    t.boolean "wednesday",                                                       :default => true
    t.boolean "thursday",                                                        :default => true
    t.boolean "friday",                                                          :default => true
    t.boolean "saturday",                                                        :default => true
    t.boolean "show_on_remote",                                                  :default => true
  end

  add_index "discounts", ["position"], :name => "index_discounts_on_position"

  create_table "dynamic_strings", :force => true do |t|
    t.string   "name"
    t.binary   "text"
    t.datetime "updated_at"
  end

  add_index "dynamic_strings", ["name"], :name => "index_dynamic_strings_on_name"

  create_table "emails", :force => true do |t|
    t.string  "smtp_address",               :limit => 64, :default => ""
    t.integer "smtp_port",                                :default => 25
    t.string  "smtp_domain",                :limit => 64, :default => ""
    t.integer "smtp_authentication_id",                   :default => 1
    t.string  "smtp_username",              :limit => 64, :default => ""
    t.string  "smtp_password",              :limit => 64, :default => ""
    t.string  "charset",                                  :default => "utf-8"
    t.string  "cc",                                       :default => ""
    t.string  "bcc",                                      :default => ""
    t.string  "sender",                                   :default => ""
    t.string  "reply",                                    :default => ""
    t.string  "confirm_subject",                          :default => "Reservation Confirmation"
    t.string  "update_subject",                           :default => "Reservation Update"
    t.string  "feedback_subject",                         :default => "Reservation Feedback"
    t.string  "remote_res_subject",                       :default => "Reservation Received"
    t.string  "remote_res_confirm_subject",               :default => "Reservation Confirmed"
    t.string  "remote_res_reject_subject",                :default => "Reservation Not Confirmed"
    t.string  "reservation_cancel_subject",               :default => "Reservation Cancelled"
    t.string  "monthly_subject",                          :default => "Monthly reservation payments"
  end

  create_table "extra_charges", :force => true do |t|
    t.integer "extra_id"
    t.integer "reservation_id"
    t.integer "number",                                         :default => 0
    t.integer "days",                                           :default => 0
    t.integer "weeks",                                          :default => 0
    t.integer "months",                                         :default => 0
    t.decimal "daily_charges",   :precision => 12, :scale => 2, :default => 0.0
    t.decimal "weekly_charges",  :precision => 12, :scale => 2, :default => 0.0
    t.decimal "monthly_charges", :precision => 12, :scale => 2, :default => 0.0
    t.decimal "initial",         :precision => 12, :scale => 2, :default => 0.0
    t.decimal "final",           :precision => 12, :scale => 2, :default => 0.0
    t.decimal "measured_charge", :precision => 12, :scale => 2, :default => 0.0
    t.date    "updated_on"
    t.decimal "charge",          :precision => 12, :scale => 2, :default => 0.0
    t.decimal "measured_rate",   :precision => 12, :scale => 6, :default => 0.0
    t.date    "created_on"
    t.integer "precision",                                      :default => 2
  end

  add_index "extra_charges", ["extra_id"], :name => "index_extra_charges_on_extra_id"
  add_index "extra_charges", ["reservation_id"], :name => "index_extra_charges_on_reservation_id"

  create_table "extras", :force => true do |t|
    t.string  "name",            :limit => 32
    t.boolean "counted",                                                      :default => false
    t.decimal "daily",                         :precision => 10, :scale => 2, :default => 0.0
    t.decimal "weekly",                        :precision => 10, :scale => 2, :default => 0.0
    t.decimal "monthly",                       :precision => 10, :scale => 2, :default => 0.0
    t.boolean "onetime",                                                      :default => false
    t.decimal "charge",                        :precision => 10, :scale => 2, :default => 0.0
    t.boolean "measured",                                                     :default => false
    t.decimal "rate",                          :precision => 12, :scale => 6, :default => 0.0
    t.string  "unit_name",       :limit => 32
    t.boolean "occasional",                                                   :default => false
    t.integer "extra_type",                                                   :default => 0
    t.integer "position"
    t.boolean "remote_display",                                               :default => true
    t.boolean "active",                                                       :default => true
    t.boolean "required",                                                     :default => false
    t.boolean "remote_required",                                              :default => false
  end

  add_index "extras", ["position"], :name => "index_extras_on_position"

  create_table "extras_taxrates", :id => false, :force => true do |t|
    t.integer "extra_id",   :null => false
    t.integer "taxrate_id", :null => false
  end

  add_index "extras_taxrates", ["extra_id"], :name => "index_extras_taxrates_on_extra_id"
  add_index "extras_taxrates", ["taxrate_id"], :name => "index_extras_taxrates_on_taxrate_id"

  create_table "groups", :force => true do |t|
    t.string  "name",            :limit => 32, :default => "", :null => false
    t.integer "expected_number",               :default => 0,  :null => false
    t.date    "startdate"
    t.date    "enddate"
    t.integer "camper_id"
  end

  create_table "integrations", :force => true do |t|
    t.string   "name",               :limit => 32,  :default => "None"
    t.string   "pp_cert_id",         :limit => 32
    t.string   "pp_business",        :limit => 128
    t.string   "pp_currency_code",   :limit => 12,  :default => "USD"
    t.string   "pp_country",         :limit => 12,  :default => "US"
    t.string   "pp_url",             :limit => 128, :default => "https://www.paypal.com/cgi-bin/webscr"
    t.string   "fd_login",           :limit => 32
    t.string   "fd_transaction_key", :limit => 32
    t.string   "fd_response_key",    :limit => 32
    t.string   "fd_currency_code",   :limit => 12,  :default => "USD"
    t.string   "fd_country",         :limit => 12,  :default => "US"
    t.string   "fd_url",             :limit => 128
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cc_merchant_id"
    t.string   "cc_api_username"
    t.string   "cc_api_password"
    t.string   "cc_endpoint",                       :default => "https://boltgw.cardconnect.com:6443"
    t.string   "cc_bolt_endpoint",                  :default => "https://bolt-uat.cardpointe.com:6443"
    t.string   "cc_bolt_api_key"
    t.string   "cc_currency_code",                  :default => "USD"
    t.string   "cc_hsn"
    t.string   "cc_greeting",                       :default => "Open Campground"
    t.boolean  "cc_use_signature",                  :default => true
    t.boolean  "cc_display_amount",                 :default => false
    t.boolean  "cc_use_cvv",                        :default => true
    t.boolean  "cc_use_zip",                        :default => true
    t.boolean  "use_pmt_dropdown",                  :default => false
    t.string   "ck_api"
    t.string   "ck_ifields_key"
    t.boolean  "ck_use_terminal",                   :default => false
  end

  create_table "mail_attachments", :force => true do |t|
    t.integer  "template_id"
    t.string   "file_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mail_templates", :force => true do |t|
    t.string   "name",       :limit => 32
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "options", :force => true do |t|
    t.boolean "use_country",                                                             :default => false
    t.boolean "use_id",                                                                  :default => false
    t.string  "unit",                      :limit => 12,                                 :default => "$"
    t.string  "separator",                 :limit => 2,                                  :default => "."
    t.string  "delimiter",                 :limit => 2,                                  :default => ","
    t.text    "header"
    t.text    "trailer"
    t.boolean "use_login",                                                               :default => false
    t.integer "sa_columns",                                                              :default => 120
    t.integer "max_spacename",                                                           :default => 3
    t.integer "disp_rows",                                                               :default => 12
    t.boolean "find_by_id",                                                              :default => false
    t.integer "no_vehicles",                                                             :default => 1
    t.integer "no_phones",                                                               :default => 1
    t.integer "lookback",                                                                :default => 7
    t.boolean "use_recommend",                                                           :default => true
    t.boolean "use_seasonal",                                                            :default => false
    t.date    "season_start",                                                            :default => '2012-01-01'
    t.date    "season_end",                                                              :default => '2012-12-31'
    t.boolean "print",                                                                   :default => false
    t.boolean "use_confirm_email",                                                       :default => false
    t.string  "res_list_sort",                                                           :default => "unconfirmed_remote desc, startdate, group_id, spaces.position asc"
    t.string  "inpark_list_sort",                                                        :default => "unconfirmed_remote desc, enddate, startdate, group_id, spaces.position asc"
    t.string  "archive_list_sort",                                                       :default => "id"
    t.boolean "use_autologin",                                                           :default => false
    t.boolean "use_override",                                                            :default => false
    t.boolean "override_by_all",                                                         :default => false
    t.boolean "use_2nd_address",                                                         :default => false
    t.boolean "use_remote_reservations",                                                 :default => false
    t.string  "home"
    t.string  "locale",                    :limit => 16,                                 :default => "en"
    t.boolean "use_checkout_time",                                                       :default => false
    t.time    "checkout_time"
    t.boolean "use_reserve_by_wk",                                                       :default => false
    t.boolean "remote_discount",                                                         :default => false
    t.boolean "remote_recommendations",                                                  :default => false
    t.boolean "use_onetime_discount",                                                    :default => false
    t.boolean "list_payments",                                                           :default => false
    t.integer "keep_reservations",                                                       :default => 13
    t.boolean "use_feedback",                                                            :default => false
    t.boolean "require_gateway",                                                         :default => true
    t.boolean "allow_gateway",                                                           :default => false
    t.boolean "auto_checkin_remote",                                                     :default => false
    t.string  "current_version",           :limit => 16
    t.string  "current_revision",          :limit => 16
    t.string  "ftp_server",                :limit => 128
    t.string  "ftp_account",               :limit => 32
    t.string  "ftp_passwd",                :limit => 32
    t.boolean "match_firstname",                                                         :default => false
    t.boolean "match_city",                                                              :default => false
    t.text    "js"
    t.text    "remote_css"
    t.text    "remote_js"
    t.boolean "variable_rates",                                                          :default => false
    t.boolean "use_update",                                                              :default => true
    t.boolean "use_cc_fee",                                                              :default => true
    t.boolean "tabs",                                                                    :default => false
    t.boolean "require_email",                                                           :default => false
    t.boolean "require_phone",                                                           :default => false
    t.text    "css"
    t.boolean "use_remote_res_email",                                                    :default => true
    t.boolean "use_remote_res_confirm",                                                  :default => true
    t.boolean "use_remote_res_reject",                                                   :default => true
    t.integer "rates_decimal",                                                           :default => 2
    t.boolean "use_rig_age",                                                             :default => true
    t.boolean "use_length",                                                              :default => true
    t.boolean "disp_site_length",                                                        :default => true
    t.boolean "use_rig_type",                                                            :default => true
    t.boolean "use_slides",                                                              :default => true
    t.boolean "use_adults",                                                              :default => true
    t.boolean "use_children",                                                            :default => true
    t.boolean "use_pets",                                                                :default => true
    t.boolean "use_remote_age",                                                          :default => true
    t.boolean "use_remote_length",                                                       :default => true
    t.boolean "disp_remote_length",                                                      :default => true
    t.boolean "use_remote_rig_type",                                                     :default => true
    t.boolean "use_remote_slides",                                                       :default => true
    t.boolean "use_remote_adults",                                                       :default => true
    t.boolean "use_remote_children",                                                     :default => true
    t.boolean "use_remote_pets",                                                         :default => true
    t.boolean "inline_subtotal",                                                         :default => false
    t.boolean "use_storage",                                                             :default => false
    t.boolean "use_closed",                                                              :default => false
    t.date    "closed_start"
    t.date    "closed_end"
    t.boolean "all_onetime_discount",                                                    :default => false
    t.boolean "all_backup",                                                              :default => true
    t.boolean "all_manage_backup",                                                       :default => false
    t.boolean "all_manage_logs",                                                         :default => false
    t.boolean "all_manage_payments",                                                     :default => false
    t.boolean "all_manage_measured",                                                     :default => false
    t.boolean "all_checkin_rpt",                                                         :default => true
    t.boolean "all_leave_rpt",                                                           :default => true
    t.boolean "all_arrival_rpt",                                                         :default => true
    t.boolean "all_departure_rpt",                                                       :default => true
    t.boolean "all_in_park_rpt",                                                         :default => true
    t.boolean "all_space_sum_rpt",                                                       :default => true
    t.boolean "all_occupancy_rpt",                                                       :default => false
    t.boolean "all_campers_rpt",                                                         :default => false
    t.boolean "all_transactions_rpt",                                                    :default => false
    t.boolean "all_payments_rpt",                                                        :default => false
    t.boolean "all_measured_rpt",                                                        :default => false
    t.boolean "all_recommend_rpt",                                                       :default => false
    t.boolean "all_archives",                                                            :default => false
    t.boolean "all_updates",                                                             :default => false
    t.boolean "show_available",                                                          :default => true
    t.boolean "show_remote_available",                                                   :default => true
    t.boolean "express",                                                                 :default => false
    t.boolean "use_discount",                                                            :default => true
    t.boolean "use_links",                                                               :default => false
    t.string  "cookie_token"
    t.string  "session_token"
    t.boolean "use_envelope",                                                            :default => false
    t.string  "margin_top",                :limit => 12,                                 :default => "0.5in"
    t.string  "margin_left",               :limit => 12,                                 :default => "0.56in"
    t.string  "margin_bottom",             :limit => 12,                                 :default => "0.5in"
    t.boolean "use_license",                                                             :default => false
    t.boolean "use_map",                                                                 :default => false
    t.boolean "use_remote_map",                                                          :default => false
    t.string  "map"
    t.string  "remote_map"
    t.boolean "edit_archives",                                                           :default => true
    t.boolean "all_edit_archives",                                                       :default => false
    t.boolean "require_first",                                                           :default => false
    t.boolean "require_addr",                                                            :default => false
    t.boolean "require_city",                                                            :default => false
    t.boolean "require_state",                                                           :default => false
    t.boolean "require_mailcode",                                                        :default => false
    t.boolean "require_country",                                                         :default => false
    t.boolean "require_id",                                                              :default => false
    t.boolean "use_addl",                                                                :default => false
    t.boolean "use_ssl",                                                                 :default => false
    t.boolean "l_require_first",                                                         :default => false
    t.boolean "l_require_addr",                                                          :default => false
    t.boolean "l_require_city",                                                          :default => false
    t.boolean "l_require_state",                                                         :default => false
    t.boolean "l_require_mailcode",                                                      :default => false
    t.boolean "l_require_country",                                                       :default => false
    t.boolean "l_require_id",                                                            :default => false
    t.boolean "l_require_phone",                                                         :default => false
    t.boolean "l_require_email",                                                         :default => false
    t.integer "deposit_type",                                                            :default => 0
    t.decimal "deposit",                                  :precision => 11, :scale => 5, :default => 0.0
    t.boolean "remote_auto_accept",                                                      :default => false
    t.string  "date_format",               :limit => 12
    t.boolean "all_reservations_rpt",                                                    :default => false
    t.boolean "all_card_transactions_rpt",                                               :default => false
    t.boolean "use_remote_sitetype",                                                     :default => true
    t.boolean "all_troubleshoot",                                                        :default => false
    t.boolean "use_variable_charge",                                                     :default => false
    t.boolean "all_manage_variable",                                                     :default => true
    t.string  "phone_home"
    t.boolean "use_measured_emails",                                                     :default => false
    t.boolean "use_long_term",                                                           :default => false
    t.boolean "require_rigtype",                                                         :default => false
    t.boolean "require_length",                                                          :default => false
    t.boolean "require_age",                                                             :default => false
    t.string  "font_family",                                                             :default => "serif"
    t.integer "font_size",                                                               :default => 9
    t.integer "sa_font_size",                                                            :default => 13
  end

  create_table "payments", :force => true do |t|
    t.decimal  "amount",                       :precision => 11, :scale => 5, :default => 0.0
    t.integer  "reservation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "memo"
    t.integer  "creditcard_id"
    t.string   "credit_card_no", :limit => 20,                                :default => ""
    t.date     "cc_expire"
    t.string   "name",           :limit => 32
    t.date     "pmt_date"
    t.decimal  "cc_fee",                       :precision => 6,  :scale => 2, :default => 0.0
    t.boolean  "refundable",                                                  :default => false
  end

  add_index "payments", ["reservation_id"], :name => "index_payments_on_reservation_id"

  create_table "paypal_transactions", :force => true do |t|
    t.decimal  "amount",         :precision => 12, :scale => 2, :default => 0.0
    t.integer  "reservation_id"
    t.integer  "payment_id"
    t.string   "encrypted"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "paypal_transactions", ["reservation_id"], :name => "index_paypal_transactions_on_reservation_id"

  create_table "prices", :force => true do |t|
    t.string "name", :limit => 32, :default => "", :null => false
  end

  create_table "prompts", :force => true do |t|
    t.string   "display",    :limit => 32
    t.string   "locale",     :limit => 16, :default => "en"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rates", :force => true do |t|
    t.integer "season_id"
    t.integer "price_id"
    t.decimal "daily_rate",      :precision => 10, :scale => 5, :default => 0.0, :null => false
    t.decimal "weekly_rate",     :precision => 10, :scale => 5, :default => 0.0, :null => false
    t.decimal "monthly_rate",    :precision => 11, :scale => 5, :default => 0.0, :null => false
    t.decimal "seasonal_rate",   :precision => 8,  :scale => 2, :default => 0.0, :null => false
    t.decimal "sunday",          :precision => 10, :scale => 5, :default => 0.0, :null => false
    t.decimal "monday",          :precision => 10, :scale => 5, :default => 0.0, :null => false
    t.decimal "tuesday",         :precision => 10, :scale => 5, :default => 0.0, :null => false
    t.decimal "wednesday",       :precision => 10, :scale => 5, :default => 0.0, :null => false
    t.decimal "thursday",        :precision => 10, :scale => 5, :default => 0.0, :null => false
    t.decimal "friday",          :precision => 10, :scale => 5, :default => 0.0, :null => false
    t.decimal "saturday",        :precision => 10, :scale => 5, :default => 0.0, :null => false
    t.decimal "monthly_storage", :precision => 11, :scale => 5, :default => 0.0
  end

  add_index "rates", ["price_id"], :name => "index_rates_on_price_id"
  add_index "rates", ["season_id"], :name => "index_rates_on_season_id"

  create_table "recommenders", :force => true do |t|
    t.string   "name",       :limit => 32
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.boolean  "active",                   :default => true
  end

  add_index "recommenders", ["position"], :name => "index_recommenders_on_position"

  create_table "remember_logins", :force => true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.datetime "token_expires"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reservations", :force => true do |t|
    t.integer  "camper_id",                                                        :default => 0,     :null => false
    t.integer  "rigtype_id",          :limit => 3,                                 :default => 0,     :null => false
    t.integer  "space_id",                                                         :default => 0,     :null => false
    t.integer  "discount_id"
    t.integer  "group_id"
    t.date     "startdate",                                                                           :null => false
    t.date     "enddate",                                                                             :null => false
    t.decimal  "deposit",                           :precision => 8,  :scale => 2, :default => 0.0
    t.decimal  "override_total",                    :precision => 8,  :scale => 2, :default => 0.0
    t.text     "special_request"
    t.integer  "slides",              :limit => 1,                                 :default => 0
    t.integer  "length",              :limit => 3,                                 :default => 0
    t.integer  "rig_age",             :limit => 3,                                 :default => 0
    t.string   "vehicle_license",     :limit => 20
    t.string   "vehicle_state",       :limit => 16
    t.boolean  "checked_in",                                                       :default => false
    t.integer  "adults",              :limit => 2,                                 :default => 2
    t.integer  "pets",                :limit => 2,                                 :default => 0
    t.integer  "kids",                :limit => 2,                                 :default => 0
    t.integer  "lock_version",                                                     :default => 0
    t.decimal  "total",                             :precision => 8,  :scale => 2, :default => 0.0
    t.boolean  "confirm",                                                          :default => false
    t.datetime "created_at"
    t.decimal  "ext_charges",                       :precision => 6,  :scale => 2, :default => 0.0
    t.text     "tax_str"
    t.decimal  "tax_amount",                        :precision => 6,  :scale => 2, :default => 0.0
    t.boolean  "unconfirmed_remote",                                               :default => false
    t.text     "log"
    t.string   "vehicle_license_2",   :limit => 20
    t.string   "vehicle_state_2",     :limit => 16
    t.integer  "recommender_id",                                                   :default => 0
    t.decimal  "seasonal_rate",                     :precision => 8,  :scale => 2, :default => 0.0
    t.decimal  "seasonal_charges",                  :precision => 8,  :scale => 2, :default => 0.0
    t.boolean  "seasonal",                                                         :default => false
    t.string   "gateway_transaction"
    t.decimal  "onetime_discount",                  :precision => 8,  :scale => 2, :default => 0.0
    t.boolean  "archived",                                                         :default => false
    t.date     "updated_on"
    t.boolean  "storage",                                                          :default => false
    t.datetime "updated_at"
    t.integer  "sitetype_id",                                                      :default => 0
    t.integer  "next"
    t.integer  "prev"
    t.boolean  "cancelled",                                                        :default => false
    t.boolean  "checked_out",                                                      :default => false
    t.boolean  "long_term_monthly",                                                :default => false
    t.decimal  "cancel_charge",                     :precision => 10, :scale => 5, :default => 0.0,   :null => false
  end

  add_index "reservations", ["enddate"], :name => "index_reservations_on_enddate"
  add_index "reservations", ["group_id"], :name => "index_reservations_on_group_id"
  add_index "reservations", ["space_id"], :name => "index_reservations_on_space_id"
  add_index "reservations", ["startdate"], :name => "index_reservations_on_startdate"

  create_table "rigtypes", :force => true do |t|
    t.string  "name",     :limit => 32, :default => "",   :null => false
    t.integer "position"
    t.boolean "active",                 :default => true
  end

  add_index "rigtypes", ["position"], :name => "index_rigtypes_on_position"

  create_table "seasons", :force => true do |t|
    t.string  "name",               :limit => 32
    t.date    "startdate"
    t.date    "enddate"
    t.boolean "applies_to_weekly",                :default => true
    t.boolean "applies_to_monthly",               :default => true
    t.boolean "active",                           :default => true
  end

  create_table "sitetypes", :force => true do |t|
    t.string  "name",      :limit => 32, :default => "",    :null => false
    t.integer "position"
    t.boolean "active",                  :default => true
    t.boolean "long_term",               :default => false
  end

  add_index "sitetypes", ["position"], :name => "index_sitetypes_on_position"

  create_table "sitetypes_taxrates", :id => false, :force => true do |t|
    t.integer "sitetype_id", :null => false
    t.integer "taxrate_id",  :null => false
  end

  add_index "sitetypes_taxrates", ["sitetype_id"], :name => "index_sitetypes_taxrates_on_sitetype_id"
  add_index "sitetypes_taxrates", ["taxrate_id"], :name => "index_sitetypes_taxrates_on_taxrate_id"

  create_table "smtp_authentications", :force => true do |t|
    t.string "name", :limit => 32
  end

  create_table "space_allocs", :force => true do |t|
    t.integer  "space_id"
    t.integer  "reservation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spaces", :force => true do |t|
    t.string  "name",              :limit => 32,                               :default => "",    :null => false
    t.boolean "power_15a",                                                     :default => false
    t.boolean "power_30a",                                                     :default => false
    t.boolean "power_50a",                                                     :default => false
    t.boolean "water",                                                         :default => false
    t.boolean "sewer",                                                         :default => false
    t.integer "length",            :limit => 3,                                :default => 0,     :null => false
    t.integer "width",             :limit => 3,                                :default => 102
    t.integer "sitetype_id",       :limit => 3,                                :default => 0,     :null => false
    t.integer "price_id",          :limit => 3,                                :default => 0,     :null => false
    t.string  "special_condition"
    t.boolean "unavailable",                                                   :default => false
    t.integer "position"
    t.boolean "remote_reservable",                                             :default => true
    t.decimal "current",                         :precision => 8, :scale => 2, :default => 0.0
    t.boolean "active",                                                        :default => true
  end

  add_index "spaces", ["position"], :name => "index_spaces_on_position"

  create_table "taxes", :force => true do |t|
    t.integer "reservation_id"
    t.string  "name",           :limit => 32
    t.string  "rate",           :limit => 32
    t.integer "count",                                                      :default => 0
    t.decimal "amount",                       :precision => 6, :scale => 2
  end

  create_table "taxrates", :force => true do |t|
    t.string  "name",                  :limit => 32
    t.boolean "is_percent",                                                        :default => false
    t.float   "percent",                                                           :default => 0.0
    t.decimal "amount",                              :precision => 6, :scale => 2, :default => 0.0
    t.boolean "apl_week",                                                          :default => false
    t.boolean "apl_month",                                                         :default => false
    t.boolean "apl_seasonal",                                                      :default => false
    t.boolean "apl_daily",                                                         :default => true
    t.boolean "weekly_charge_daily",                                               :default => true
    t.boolean "monthly_charge_daily",                                              :default => true
    t.boolean "seasonal_charge_daily",                                             :default => true
    t.integer "position"
    t.boolean "active",                                                            :default => true
    t.boolean "apl_storage",                                                       :default => false
  end

  add_index "taxrates", ["position"], :name => "index_taxrates_on_position"

  create_table "taxrates_variable_charges", :id => false, :force => true do |t|
    t.integer "variable_charge_id", :null => false
    t.integer "taxrate_id",         :null => false
  end

  add_index "taxrates_variable_charges", ["taxrate_id"], :name => "index_taxrates_variable_charges_on_taxrate_id"
  add_index "taxrates_variable_charges", ["variable_charge_id"], :name => "index_taxrates_variable_charges_on_variable_charge_id"

  create_table "users", :force => true do |t|
    t.string   "name",                   :limit => 32
    t.string   "hashed_password"
    t.string   "salt"
    t.boolean  "admin",                                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "remember_me",                          :default => false
    t.string   "remember_token"
    t.datetime "remember_token_expires"
  end

  create_table "variable_charges", :force => true do |t|
    t.integer  "reservation_id"
    t.string   "detail"
    t.decimal  "amount",         :precision => 12, :scale => 2, :default => 0.0
    t.boolean  "taxable",                                       :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", :force => true do |t|
    t.string  "release",         :limit => 16
    t.string  "revision",        :limit => 16
    t.text    "description"
    t.boolean "install_pending",               :default => true
  end

end
