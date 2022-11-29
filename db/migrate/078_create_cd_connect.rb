class CreateCdConnect < ActiveRecord::Migration
  def self.up
    change_column :options, :require_gateway, :boolean, :default => true
    change_column :options, :allow_gateway, :boolean, :default => false
    change_column :integrations,  :name, :string,   :limit => 32, :default => 'None'
    add_column :options, :all_reservations_rpt, :boolean, :default => false
    add_column :options, :all_card_transactions_rpt, :boolean, :default => false
    add_column :integrations, :cc_merchant_id, :string
    add_column :integrations, :cc_api_username, :string
    add_column :integrations, :cc_api_password, :string
    add_column :integrations, :cc_endpoint, :string, :default => 'https://boltgw.cardconnect.com:6443'
    add_column :integrations, :cc_bolt_endpoint, :string, :default => 'https://bolt-uat.cardpointe.com:6443'
    add_column :integrations, :cc_bolt_api_key, :string
    add_column :integrations, :cc_currency_code, :string, :default => 'USD'
    add_column :integrations, :cc_hsn, :string
    add_column :integrations, :cc_greeting, :string, :default => 'Open Campground'
    add_column :integrations, :cc_use_signature, :boolean, :default => true # require signature on transactions where supported
    add_column :integrations, :cc_display_amount, :boolean, :default => false # display amount on transactions
    add_column :integrations, :cc_use_cvv, :boolean, :default => true # require cvv on transactions
    add_column :integrations, :cc_use_zip, :boolean, :default => true # require zip code on transactions
    create_table :card_transactions do |t|
      #####################################
      # items used in request and response
      #####################################
      t.string  :account
      t.string  :expiry
      t.decimal :amount, :precision => 12, :scale => 2, :default => 0.0
      t.string  :currency, :default => 'USD'
      t.string  :retref
      # merchid (from Integrations, discarded on resp)
      #####################################
      # items used in request only
      #####################################
      # hsn (from Integrations)
      # datetime (from Time)
      # capture (hardcoded)
      # includeSignature (from Integrations)
      # includeAVS (from Integrations)
      # includeAmountDisplay (from Integrations)
      # includePIN (hardcoded)
      # beep (hardcoded)
      # force (hardcoded)
      t.integer :reservation_id # used as orderid
      #####################################
      # items used in response
      #####################################
      t.string  :authcode
      t.string  :avsresp
      t.string  :batchid
      t.string  :cvvresp
      t.string  :name
      t.string  :respproc
      t.string  :resptext
      t.string  :respcode
      t.string  :respstat
      t.string  :signature
      t.string  :token
      #####################################
      # others
      #####################################
      t.string  :accttype
      t.string  :address
      t.string  :city
      t.string  :region
      t.string  :country
      t.string  :postal
      t.string  :ecomind
      t.string  :track
      t.string  :tokenize
      t.string  :mytoken
      t.integer :payment_id
      t.boolean :card_present
      t.string  :session_key
      t.timestamps
    end
    add_index  :card_transactions, :reservation_id
    int = Integration.first_or_create
    int.update_attributes :name => 'None' if int.name == 'none' || int.name == nil
    Prompt.find_by_display('show').update_attributes :display => 'old-show' unless Prompt.find_by_display('old-show')
    Prompt.create!(:display => 'show',
		   :body =>"This is your last chance to change things before you complete your reservation.
			    Any fields that are boxed can be modified by selecting them and typing the new data.
			    To change date or space select the buttons so labeled.
			    <p> 
			    Select the <em>Complete Reservation</em> button to continue the reservation process on the Camper Name page.</p>")
    Prompt.create!(:display => 'CardConnect-payment',
		   :body =>"This page is your secure credit card gateway.  Enter your credit card number, expiration date and security code as prompted then select 'Submit'")
    Prompt.create!(:display => 'PayPal-payment',
		   :body =>"Review the amount to be charged using PayPal and then select the PayPal Buy Now button.  This button will take you to the PayPal secure payments page.")

    Prompt.create!(:display => 'CardConnect-a-payment',
		   :body =>"This page is your secure credit card gateway.  Enter your credit card number, expiration date and security code as prompted then select 'Submit'<p>If you will not be paying now select Finish Reservation.")
    Prompt.create!(:display => 'PayPal-a-payment',
		   :body =>"Review the amount to be charged using PayPal and then select the PayPal Buy Now button.  This button will take you to the PayPal secure payments page.<p>If you will not be paying now select Finish Reservation.")
  end

  def self.down
    remove_column :options, :all_reservations_rpt
    remove_column :options, :all_card_transactions_rpt
    remove_column :integrations, :cc_merchant_id
    remove_column :integrations, :cc_api_username
    remove_column :integrations, :cc_api_password
    remove_column :integrations, :cc_endpoint
    remove_column :integrations, :cc_bolt_endpoint
    remove_column :integrations, :cc_bolt_api_key
    remove_column :integrations, :cc_currency_code
    remove_column :integrations, :cc_hsn
    remove_column :integrations, :cc_greeting
    remove_column :integrations, :cc_use_signature
    remove_column :integrations, :cc_display_amount
    remove_column :integrations, :cc_use_cvv
    remove_column :integrations, :cc_use_zip
    remove_index  :card_transactions, :reservation_id
    drop_table :card_transactions
    Prompt.all(:conditions => 'display like \'%payment\'').each {|p| p.destroy}
    begin
      Prompt.create! :display => 'show', :body => 'deleted'
    rescue
    end
  end
end
