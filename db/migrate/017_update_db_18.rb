class UpdateDb18 < ActiveRecord::Migration
  def self.up
    create_table "smtp_authentications" do |e|
      e.string :name, :limit => 16
    end
    [ {'name' => 'none'},
      {'name' => 'plain'},
      {'name' => 'login'},
      {'name' => 'cram_md5'} ].each do |e|
      auth = SmtpAuthentication.new e
      auth.save
    end

    add_column :options, :use_confirm_email, :boolean, :default => false
    create_table "emails" do |e|
      e.string "smtp_address", :limit => 64, :default => ''
      e.integer "smtp_port", :default => 25
      e.string "smtp_domain", :limit => 64, :default => ''
      e.integer "smtp_authentication_id", :default => 1
      e.string "smtp_username", :limit => 64, :default => ''
      e.string "smtp_password", :limit => 64, :default => ''
      e.string "charset", :default => 'utf-8'
      e.string "cc", :default => ''
      e.string "bcc", :default => ''
      e.string "sender", :default => ''
      e.string "reply", :default => ''
      e.string "confirm_subject", :default => 'Reservation Confirmation'
    end

    create_table :mail_templates do |t|
      t.string :name
      t.text :body

      t.timestamps
    end

    MailTemplate.create!(:name => "reservation_confirmation", :body => "Dear {{camper}},\n\nThank you for making a reservation at My RV Park.  You are scheduled to arrive on {{start}} and depart on {{departure}}.  We have assigned you site {{space_name}}.  The total charges are estimated at {{charges}}.  Your reservation confirmation number is {{number}}.\n\nWe look forward to serving you\nTy Coon\nManager")
    MailTemplate.create!(:name => "tst", :body => "This is a test message")

    add_column :extras, :onetime, :boolean, :default => false
    add_column :extras, :onetime_charge, :decimal, :precision => 6, :scale => 2, :default => 0.0
    add_column :extra_charges, :onetime_charge, :decimal, :precision => 6, :scale => 2, :default => 0.0

    add_column :options,
    	       :res_list_sort,
	       :string,
	       :default => "unconfirmed_remote desc, startdate, group_id, spaces.position asc"
    add_column :options,
	       :inpark_list_sort,
	       :string,
	       :default => "unconfirmed_remote desc, enddate, startdate, group_id, spaces.position asc"
    add_column :options,
	       :archive_list_sort,
	       :string,
	       :default => "id"
    add_column :archives, :reservation_id, :integer, :default => 0
    add_column :archives, :selected, :boolean, :default => false
    add_column :spaces, :position, :integer

    add_index  :spaces, :position

    Space.reset_column_information
    Space.find(:all).each do |sp|
      sp.update_attribute :position, sp.id
    end

    add_column :options, :use_autologin, :boolean, :default => false
    add_column :users, :remember_me,     :boolean, :default => false
    add_column :users, :remember_token, :string
    add_column :users, :remember_token_expires, :datetime

    add_column :options, :use_override, :boolean, :default => false
    add_column :options, :override_by_all, :boolean, :default => false
    rename_column :reservations, :total_charge, :override_total
#   add_column :options, :use_one_time_discount, :boolean, :default => false
#   add_column :options, :otd_by_all, :boolean, :default => false
#   add_column :reservations, :one_time_discount, :decimal, :precision => 6, :scale => 2, :default => 0.0

    add_column :options, :use_2nd_address, :boolean, :default => false
    add_column :campers, :address2, :string, :limit => 32
    add_column :archives, :address2, :string, :limit => 32

  end

  def self.down

    remove_index :spaces, :position

    remove_column :options, :use_confirm_email
    drop_table :smtp_authentications
    drop_table :emails
    drop_table :mail_templates
    remove_column :extras, :onetime
    remove_column :extras, :onetime_charge
    remove_column :extra_charges, :onetime_charge
    remove_column :options, :res_list_sort
    remove_column :options, :inpark_list_sort
    remove_column :options, :archive_list_sort
    remove_column :archives, :reservation_id
    remove_column :archives, :selected
    remove_column :spaces, :position

    remove_column :options, :use_autologin
    remove_column :users, :remember_me
    remove_column :users, :remember_token
    remove_column :users, :remember_token_expires

    remove_column :options, :use_override
    remove_column :options, :override_by_all
    rename_column :reservations, :override_total, :total_charge
#   remove_column :options, :use_one_time_discount
#   remove_column :options, :otd_by_all
#   remove_column :reservations, :one_time_discount
    remove_column :options, :use_2nd_address
    remove_column :campers, :address2
    remove_column :archives, :address2

  end
end
