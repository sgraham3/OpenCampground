class CreateIntegrations < ActiveRecord::Migration
  def self.up
    create_table :integrations do |t|
      t.string :name
      t.string :pp_cert_id
      t.string :pp_business
      t.string :pp_currency_code, :default => 'USD'
      t.string :pp_country, :default => 'US'
      t.string :pp_url, :default => 'https://www.paypal.com/cgi-bin/webscr' 
      t.string :fd_login
      t.string :fd_transaction_key
      t.string :fd_response_key
      t.string :fd_currency_code, :default => 'USD'
      t.string :fd_country, :default => 'US'
      t.string :fd_url
      t.timestamps
    end

    opt = Option.first

    if opt.require_paypal || opt.allow_paypal
      g=Integration.create 
      g.update_attributes( :name => 'PayPal',
		      :pp_cert_id => opt.paypal_cert_id,
		      :pp_business => opt.paypal_business,
		      :pp_currency_code => opt.paypal_currency_code,
		      :pp_country => opt.paypal_country,
		      :pp_url => opt.paypal_url )
    end
    rename_column :options, :require_paypal, :require_gateway
    rename_column :options, :allow_paypal, :allow_gateway
    rename_column :reservations, :paypal_transaction, :gateway_transaction
    remove_column :options, :paypal_cert_id
    remove_column :options, :paypal_business
    remove_column :options, :paypal_currency_code
    remove_column :options, :paypal_country
    remove_column :options, :paypal_url
  end

  def self.down
    add_column :options, :paypal_cert_id, :string
    add_column :options, :paypal_business, :string
    add_column :options, :paypal_currency_code, :string, :default => 'USD'
    add_column :options, :paypal_country, :string, :default => 'US'
    add_column :options, :paypal_url, :string, :default => 'https://www.paypal.com/cgi-bin/webscr' 
    rename_column :options, :require_gateway, :require_paypal
    rename_column :options, :allow_gateway, :allow_paypal
    rename_column :reservations, :gateway_transaction, :paypal_transaction
    # remove_column :options, :integration
    int = Integration.first
    opt = Option.first
    if int && int.name == 'PayPal'
      opt.update_attributes( :paypal_cert_id => int.pp_cert_id,
			     :paypal_business => int.pp_business,
			     :paypal_currency_code => int.pp_currency_code,
			     :paypal_country => int.pp_country,
			     :paypal_url => int.pp_url )
    end
    drop_table :integrations
  end

end
