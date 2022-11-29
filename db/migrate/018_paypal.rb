class Paypal < ActiveRecord::Migration
  def self.up
    add_column :options, :use_remote_reservations, :boolean, :default => false
    add_column :options, :paypal_cert_id, :string
    add_column :options, :paypal_business, :string
    add_column :options, :paypal_currency_code, :string, :default => 'USD'
    add_column :options, :paypal_country, :string, :default => 'US'
    add_column :options, :paypal_url, :string, :default => 'https://www.paypal.com/cgi-bin/webscr' 
    add_column :options, :home, :string
    add_column :reservations, :paypal_transaction, :string
    add_column :spaces, :remote_reservable, :boolean, :default => true
  end

  def self.down
    remove_column :options, :use_remote_reservations
    remove_column :options, :paypal_cert_id
    remove_column :options, :paypal_business
    remove_column :options, :paypal_currency_code
    remove_column :options, :paypal_country
    remove_column :options, :paypal_url
    remove_column :options, :home
    remove_column :reservations, :paypal_transaction
    remove_column :spaces, :remote_reservable
    drop_table :explanations
  end
end
