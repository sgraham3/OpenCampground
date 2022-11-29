class RemoteConfirm < ActiveRecord::Migration
  def self.up
    # add distinct remote reservation confirm email capability
    add_column :options, :use_remote_res_email, :boolean, :default => true
    add_column :options, :use_remote_res_confirm, :boolean, :default => true
    add_column :options, :use_remote_res_reject, :boolean, :default => true
    add_column :emails, :remote_res_subject, :string, :default => 'Reservation Received'
    add_column :emails, :remote_res_confirm_subject, :string, :default => 'Reservation Confirmed'
    add_column :emails, :remote_res_reject_subject, :string, :default => 'Reservation Not Confirmed'
    MailTemplate.create!(:name => "remote_reservation_received", :body =>"Dear {{camper}},\n\nThank you for making a reservation at My RV Park.  Your reservation will be reviewed by the management and you will sent a confirmation.  \n\nWe look forward to serving you\nTy Coon\nManager")
    MailTemplate.create!(:name => "remote_reservation_confirmation", :body =>"Dear {{camper}},\n\nThank you for making a reservation at My RV Park.  You are scheduled to arrive on {{start}} and depart on {{departure}}.  We have assigned you site {{space_name}}.  The total charges are estimated at {{charges}}.  Your reservation confirmation number is {{number}}. \n\nWe look forward to serving you\nTy Coon\nManager")
    MailTemplate.create!(:name => "remote_reservation_reject", :body =>"Dear {{camper}},\n\nYour reservation for arrival on {{start}} and departure on {{departure}} has not been confirmed.  Please call us at (111) 555-1212 to resolve the problems.  \n\nWe look forward to serving you\nTy Coon\nManager")
  end

  def self.down
    remove_column :options, :use_remote_res_email
    remove_column :options, :use_remote_res_confirm
    remove_column :options, :use_remote_res_reject
    remove_column :emails, :remote_res_subject
    remove_column :emails, :remote_res_confirm_subject
    remove_column :emails, :remote_res_reject_subject
    MailTemplate.find_by_name("remote_reservation_received").destroy
    MailTemplate.find_by_name("remote_reservation_confirmation").destroy
    MailTemplate.find_by_name("remote_reservation_reject").destroy
  end
end
