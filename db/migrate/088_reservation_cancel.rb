class ReservationCancel < ActiveRecord::Migration
  def self.up
    add_column :emails, :reservation_cancel_subject, :string, :default => 'Reservation Cancelled'
    MailTemplate.create!(:name => "reservation_cancel",
			 :body => "Dear {{camper}},\n\nYour reservation {{number}} for {{start}} to {{departure}} has been canceled..  The reason for the cancellation is: {{reason}}.\n\nWe look forward to serving you in the future.\nManager")
  end

  def self.down
    remove_column :emails, :reservation_cancel_subject
    MailTemplate.find_by_name("reservation_cancel").destroy
  end
end
