class Size < ActiveRecord::Migration
  def self.up
    change_column :archives, :name, :string, :limit => 66
    change_column :archives, :vehicle_state, :string, :limit => 16
    change_column :archives, :discount_name,  :string, :limit => 32,    :default => ""
    change_column :archives, :rigtype_name,  :string, :limit => 32,    :default => ""
    change_column :archives, :space_name,  :string,  :limit => 32,    :default => ""
    change_column :archives, :group_name,  :string,  :limit => 32
    change_column :archives, :vehicle_state_2,  :string, :limit => 16
    change_column :archives, :recommender, :string, :limit => 32
    change_column :archives, :country, :string, :limit => 32
    change_column :campers, :last_name,  :string, :limit => 32,   :null => false
    change_column :campers, :first_name,  :string, :limit => 32,   :null => false
    change_column :campers,  :state,  :string,  :limit => 16,  :default => "", :null => false
    change_column :countries, :name, :string, :limit => 32
    change_column :creditcards, :name, :string, :limit => 32
    change_column :date_fmts, :name, :string,  :limit => 32
    change_column :discounts,  :name,  :string,  :limit => 32,     :default => "", :null => false
    change_column :extra_charges, :daily_charges,  :decimal, :precision => 12, :scale => 2, :default => 0.0
    change_column :extra_charges, :weekly_charges, :decimal, :precision => 12, :scale => 2, :default => 0.0
    change_column :extra_charges, :monthly_charges, :decimal, :precision => 12, :scale => 2, :default => 0.0
    change_column :extra_charges, :initial,  :decimal, :precision => 12, :scale => 2, :default => 0.0
    change_column :extra_charges, :final,   :decimal, :precision => 12, :scale => 2, :default => 0.0
    change_column :extra_charges, :measured_charge, :decimal, :precision => 12, :scale => 2, :default => 0.0
    change_column :extra_charges, :charge,  :decimal, :precision => 12, :scale => 2, :default => 0.0
    change_column :extra_charges, :measured_rate,  :decimal, :precision => 12, :scale => 6, :default => 0.0
    change_column :extras,  :name,  :string,  :limit => 32
    change_column :extras, :daily,   :decimal, :precision => 10, :scale => 2, :default => 0.0
    change_column :extras, :weekly,    :decimal, :precision => 10, :scale => 2, :default => 0.0
    change_column :extras, :monthly,    :decimal, :precision => 10, :scale => 2, :default => 0.0
    change_column :extras, :charge,    :decimal, :precision => 10, :scale => 2, :default => 0.0
    change_column :extras, :rate,    :decimal, :precision => 12, :scale => 6, :default => 0.0
    change_column :extras,  :unit_name,  :string,  :limit => 32
    change_column :groups,  :name,  :string,  :limit => 32, :default => "", :null => false
    change_column :integrations,  :name, :string,   :limit => 32
    change_column :integrations,  :pp_cert_id,  :string,  :limit => 32
    change_column :integrations,  :pp_business,  :string,  :limit => 32
    change_column :integrations,  :pp_currency_code,  :string, :limit => 12, :default => "USD"
    change_column :integrations,  :pp_country, :string, :limit => 12, :default => "US"
    change_column :integrations,  :pp_url,  :string,   :limit => 128, :default => "https://www.paypal.com/cgi-bin/webscr"
    change_column :integrations,  :fd_login, :string,  :limit => 32
    change_column :integrations,  :fd_transaction_key, :string,:limit => 32
    change_column :integrations,  :fd_response_key, :string,  :limit => 32
    change_column :integrations,  :fd_currency_code, :string, :limit => 12, :default => "USD"
    change_column :integrations,  :fd_country,  :string,  :limit => 12, :default => "US"
    change_column :integrations,  :fd_url, :string,  :limit => 128
    change_column :mail_templates,  :name, :string,  :limit => 32
    change_column :options,  :current_version, :string,  :limit => 16
    change_column :options,  :current_revision, :string, :limit => 16
    change_column :options,  :ftp_server,  :string,  :limit => 128
    change_column :options,  :ftp_account,  :string,  :limit => 32
    change_column :options,  :ftp_passwd, :string,  :limit => 32
    change_column :options,  :margin_top, :string,  :limit => 12, :default => "0.5in"
    change_column :options,  :margin_left, :string,  :limit => 12, :default => "0.56in"
    change_column :options,  :margin_bottom, :string,  :limit => 12, :default => "0.5in"
    change_column :payments,  :name,  :string, :limit => 32
    change_column :prices, :name, :string,:limit => 32, :default => "", :null => false
    change_column :recommenders, :name,  :string, :limit => 32
    change_column :prompts, :display,  :string, :limit => 32
    change_column :reservations, :vehicle_state, :string,  :limit => 16
    change_column :reservations, :vehicle_state_2, :string, :limit => 16
    remove_column :reservations, :days
    remove_column :reservations, :daily_rate
    remove_column :reservations, :daily_disc
    remove_column :reservations, :day_charges
    remove_column :reservations, :weeks
    remove_column :reservations, :weekly_rate
    remove_column :reservations, :weekly_disc
    remove_column :reservations, :week_charges
    remove_column :reservations, :months
    remove_column :reservations, :monthly_rate
    remove_column :reservations, :monthly_disc
    remove_column :reservations, :month_charges
    remove_column :reservations, :discount_name
    remove_column :reservations, :discount_percent
    remove_column :reservations, :sales_tax
    remove_column :reservations, :sales_tax_str
    remove_column :reservations, :local_tax
    remove_column :reservations, :local_tax_str
    remove_column :reservations, :room_tax
    remove_column :reservations, :room_tax_str
    change_column :rigtypes,  :name, :string, :limit => 32, :default => "",  :null => false
    change_column :seasons,  :name, :string,  :limit => 32
    change_column :sitetypes,  :name,  :string,  :limit => 32, :default => "",  :null => false
    change_column :smtp_authentications, :name, :string,:limit => 32
    change_column :spaces,  :name, :string,  :limit => 32
    change_column :taxes,  :name,:string, :limit => 32
    change_column :taxes,  :rate,:string, :limit => 32
    change_column :taxrates,  :name, :string,   :limit => 32
    change_column :users,  :name,	:string,	:limit => 32
    change_column :versions,  :release,:string,		:limit => 16
    change_column :versions,  :revision,:string,		:limit => 16
  end

  def self.down
    change_column :archives,  :name, :string,  :limit => 32, :default => "", :null => false
    change_column :archives,  :vehicle_state, :string,  :limit => 4
    change_column :archives,  :discount_name, :string, :limit => 24,    :default => ""
    change_column :archives,  :rigtype_name, :string, :limit => 12,    :default => ""
    change_column :archives,  :space_name, :string,  :limit => 24,    :default => ""
    change_column :archives,  :group_name, :string,  :limit => 24
    change_column :archives, :vehicle_state_2, :string, :limit => 4
    change_column :archives, :recommender, :string, :limit => 20
    change_column :campers,  :last_name, :string,  :limit => 28,   :null => false
    change_column :campers,  :first_name, :string, :limit => 28,   :null => false
    change_column :campers, :state,  :string, :limit => 4,  :default => "", :null => false
    change_column :countries, :name, :string, :limit => 20
    change_column :date_fmts,:name, :string, :limit => 16
    change_column :discounts,  :name,:string,   :limit => 24,     :default => "", :null => false
    change_column :extra_charges, :daily_charges,  :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column :extra_charges, :weekly_charges, :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column :extra_charges, :monthly_charges, :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column :extra_charges, :initial,  :decimal, :precision => 8, :scale => 2, :default => 0.0
    change_column :extra_charges, :final,   :decimal, :precision => 8, :scale => 2, :default => 0.0
    change_column :extra_charges, :measured_charge, :decimal, :precision => 8, :scale => 2, :default => 0.0
    change_column :extra_charges, :charge,  :decimal, :precision => 8, :scale => 2, :default => 0.0
    change_column :extra_charges, :measured_rate,  :decimal, :precision => 10, :scale => 4, :default => 0.0
    change_column :extras,  :name, :string,  :limit => 16
    change_column :extras, :daily,   :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column :extras, :weekly,    :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column :extras, :monthly,    :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column :extras, :charge,    :decimal, :precision => 6, :scale => 2, :default => 0.0
    change_column :extras, :rate,    :decimal, :precision => 10, :scale => 4, :default => 0.0
    change_column :extras,  :unit_name, :text 
    change_column :groups,  :name, :string,  :limit => 24, :default => "", :null => false
    change_column :integrations,  :name, :string
    change_column :integrations,  :pp_cert_id, :string
    change_column :integrations,  :pp_business, :string
    change_column :integrations,  :pp_currency_code,:string,  :default => "USD"
    change_column :integrations,  :pp_country, :string, :default => "US"
    change_column :integrations,  :pp_url, :string,  :default => "https://www.paypal.com/cgi-bin/webscr"
    change_column :integrations,  :fd_login, :string
    change_column :integrations,  :fd_transaction_key, :string
    change_column :integrations,  :fd_response_key, :string
    change_column :integrations,  :fd_currency_code,:string,  :default => "USD"
    change_column :integrations,  :fd_country, :string,  :default => "US"
    change_column :integrations,  :fd_url, :string
    change_column :mail_templates,  :name, :string
    change_column :options,  :current_version, :string
    change_column :options,  :current_revision, :string
    change_column :options,  :ftp_server, :string
    change_column :options,  :ftp_account, :string
    change_column :options,  :ftp_passwd, :string
    change_column :options,  :margin_top,   :string,   :default => "0.5in"
    change_column :options,  :margin_left,   :string,  :default => "0.56in"
    change_column :options,  :margin_bottom,  :string,   :default => "0.5in"
    change_column :payments, :name, :string
    change_column :prices, :name,:string, :limit => 24, :default => "", :null => false
    change_column :recommenders, :name,:string,  :limit => 20
    change_column :reservations, :vehicle_state,:string,  :limit => 4
    change_column :reservations, :vehicle_state_2,:string, :limit => 4
    add_column :reservations,  :daily_rate,   :decimal, :precision => 6, :scale => 2, :default => 0.0
    add_column :reservations,  :daily_disc,   :decimal, :precision => 6, :scale => 2, :default => 0.0
    add_column :reservations,  :day_charges,    :decimal, :precision => 8, :scale => 2, :default => 0.0
    add_column :reservations,  :weekly_rate,    :decimal, :precision => 6, :scale => 2, :default => 0.0
    add_column :reservations,  :weekly_disc,    :decimal, :precision => 6, :scale => 2, :default => 0.0
    add_column :reservations,  :week_charges,    :decimal, :precision => 8, :scale => 2, :default => 0.0
    add_column :reservations,  :months,    :decimal, :precision => 7, :scale => 2, :default => 0.0
    add_column :reservations,  :monthly_rate,    :decimal, :precision => 7, :scale => 2, :default => 0.0
    add_column :reservations,  :monthly_disc,    :decimal, :precision => 6, :scale => 2, :default => 0.0
    add_column :reservations,  :month_charges,   :decimal, :precision => 8, :scale => 2, :default => 0.0
    add_column :reservations,  :discount_name, :string,  :limit => 24,     :default => ""
    add_column :reservations,  :discount_percent,   :decimal, :precision => 5, :scale => 2, :default => 0.0
    add_column :reservations,  :sales_tax, :integer, :default => 0
    add_column :reservations,  :sales_tax_str, :string, :limit => 24,     :default => ""
    add_column :reservations,  :local_tax, :integer, :default => 0
    add_column :reservations,  :local_tax_str, :string,  :limit => 24,     :default => ""
    add_column :reservations,  :room_tax, :integer, :default => 0
    add_column :reservations,  :room_tax_str, :string,  :limit => 24,     :default => ""
    change_column :rigtypes,  :name,:string, :limit => 12, :default => "",  :null => false
    change_column :seasons,  :name, :string
    change_column :sitetypes,  :name, :string, :limit => 12, :default => "",  :null => false
    change_column :smtp_authentications, :name,:string, :limit => 16
    change_column :spaces,  :name, :string, :limit => 24, :default => "", :null => false
    change_column :taxes,  :name, :string
    change_column :taxes,  :rate, :string
    change_column :taxrates,  :name, :string,  :limit => 16
    change_column :users,  :name, :string
    change_column :versions,  :release, :string
    change_column :versions,  :revision, :string
  end
end
