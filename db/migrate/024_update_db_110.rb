class UpdateDb110 < ActiveRecord::Migration
  def self.up
    # temporarily save space allocations for group res in db
    create_table :space_allocs do |t|
      t.integer :space_id
      t.integer :reservation_id
      t.timestamps
    end

    # remember multiple logins 
    create_table :remember_logins do |t|
      t.integer  :user_id
      t.string   :token
      t.datetime :token_expires
      t.timestamps
    end

    # expand header and trailer
    change_column :options, :header, :text
    change_column :options, :trailer, :text

    # move creditcard info to payments from reservation
    add_column :payments, :creditcard_id, :integer, :default => nil
    add_column :payments, :credit_card_no, :string, :limit => 20, :default => ""
    add_column :payments, :cc_expire, :date
    add_column :payments, :cvv2, :integer
    add_column :payments, :name, :string
    Reservation.find(:all, :conditions => ["confirm = ?", true]).each do |r|
      Payment.find_all_by_reservation_id(r.id).each do |pmt|
	if r.creditcard_id == 0
	  pmt.creditcard_id = 1
	else
	  pmt.creditcard_id = r.creditcard_id
	end
	pmt.credit_card_no = r.credit_card_no
	pmt.cc_expire = r.cc_expire
	pmt.cvv2 = r.cvv2
	pmt.save
      end
    end
    remove_column :reservations, :creditcard_id
    remove_column :reservations, :credit_card_no
    remove_column :reservations, :cc_expire
    remove_column :reservations, :cvv2
    remove_column :reservations, :expdate # unused

    # add options for reserve by week and disc and recommend on remote res
    add_column :options, :use_reserve_by_wk, :boolean, :default => false
    add_column :options, :remote_discount, :boolean, :default => false
    add_column :options, :remote_recommendations, :boolean, :default => false

    # add one time discount
    add_column :options, :use_onetime_discount, :boolean, :default => false
    add_column :reservations, :onetime_discount, :decimal, :precision => 8, :scale => 2, :default => 0.0

    # add option to list payments on res lists
    add_column :options, :list_payments, :boolean, :default => false

    # add archived so we can keep reservations around for a while
    add_column :archives, :payments, :text
    add_column :reservations, :archived, :boolean, :default => false
    add_column :reservations, :updated_on, :date
    add_column :options, :keep_reservations, :integer, :default => 13

    # add feedback email capability
    add_column :options, :use_feedback, :boolean, :default => false
    add_column :emails, :feedback_subject, :string, :default => 'Reservation Feedback'
    MailTemplate.create!(:name => "reservation_feedback", :body => "Dear {{camper}},\n\nThank you for staying at My RV Park.\n\nPlease reply to this message and tell us how you enjoyed your stay and if there is anything we could do to make your next stay with us more enjoyable.\n\nWe enjoyed having your company\nTy Coon\nManager")

    # add options for the remote reservation facility
    add_column :options, :require_paypal, :boolean, :default => false
    add_column :options, :allow_paypal, :boolean, :default => true
    add_column :options, :auto_checkin_remote, :boolean, :default => false

    # add capability of having not taxable extra
    add_column :extras, :taxable, :boolean, :default => true

  end

  def self.down
    drop_table :space_allocs
    drop_table :remember_logins
    change_column :options, :header, :string
    change_column :options, :trailer, :string
    remove_column :payments, :creditcard_id
    remove_column :payments, :credit_card_no
    remove_column :payments, :cc_expire
    remove_column :payments, :cvv2
    add_column :reservations, :creditcard_id, :integer
    add_column :reservations, :credit_card_no, :string, :limit => 20, :default => ""
    add_column :reservations, :expdate, :date
    add_column :reservations, :cc_expire, :date
    add_column :reservations, :cvv2, :integer
    remove_column :options, :use_reserve_by_wk
    remove_column :options, :remote_discount
    remove_column :options, :remote_recommendations
    remove_column :options, :list_payments
    remove_column :archives, :payments
    remove_column :reservations, :archived
    remove_column :reservations, :updated_on
    remove_column :options, :keep_reservations
    remove_column :options, :use_feedback
    remove_column :emails, :feedback_subject
    remove_column :options, :require_paypal
    remove_column :options, :allow_paypal
    remove_column :options, :auto_checkin_remote
    remove_column :extras, :taxable
  end
end
