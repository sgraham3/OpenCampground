class CreateCardKnox < ActiveRecord::Migration
  def self.up
    begin
      add_column :integrations, :ck_api, :string
    rescue # ignore the error, column already there
    end
    int = Integration.first_or_create
    Prompt.create!(:display => 'CardKnox-payment',
		   :body =>"This page is your secure credit card gateway.  Enter your credit card number, expiration date and security code as prompted then select 'Submit'")
    Prompt.create!(:display => 'CardKnox-a-payment',
		   :body =>"This page is your secure credit card gateway.  Enter your credit card number, expiration date and security code as prompted then select 'Submit'<p>If you will not be paying now select Finish Reservation.")
    create_table :ck_transactions do |t|
      t.boolean :receiptData, :default => false
      #####################################
      # items used in request and response
      #####################################
      t.integer :process_mode
      t.string  :token
      # amount in dollars and cents
      t.decimal :amount, :precision => 12, :scale => 2, :default => 0.0
      t.string  :currency, :default => 'USD'
      # in accessor :xCVV
      t.integer :reservation_id
      t.string  :month
      t.string  :year
      t.string  :card_brand
      t.string  :action
      #####################################
      # items in response
      #####################################
      t.string  :result
      t.string  :status
      t.string  :error
      t.string  :authcode
      t.string  :retref
      t.string  :batchid
      t.string  :avscode
      t.string  :avsresp
      t.string  :cvvcode
      t.string  :cvvtext
      t.string  :respcode
      t.string  :resptext
      t.string  :masked_card_num
      #####################################
      # others
      #####################################
      t.integer :payment_id
      t.timestamps
    end
    add_index  :ck_transactions, :reservation_id
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
    remove_column :integrations, :ck_api
    Prompt.all(:conditions => 'display like \'CardKnox%\'').each {|p| p.destroy}
    begin
      Prompt.create! :display => 'show', :body => 'deleted'
    rescue
    end
    drop_table :ck_transactions
  end
end
