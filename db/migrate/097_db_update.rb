class DbUpdate < ActiveRecord::Migration
  # take care of limited text for special requests and get 
  # ready for long term monthly reservations
  def self.up
    change_column :archives, :special_request, :text
    change_column :reservations, :special_request, :text
    add_column :emails, :monthly_subject, :string,  :default => "Monthly reservation payments"
    add_column :options, :use_measured_emails, :boolean,:default => false
    add_column :options, :use_long_term, :boolean,:default => false
    add_column :reservations, :long_term_monthly, :boolean,:default => false
    add_column :sitetypes, :long_term, :boolean,:default => false
  end

  def self.down
    change_column :archives, :special_request, :string
    change_column :reservations, :special_request, :string
    remove_column :emails, :monthly_subject
    remove_column :options, :use_measured_emails
    remove_column :options, :use_long_term
    remove_column :reservations, :long_term_monthly
    remove_column :sitetypes, :long_term
  end
end

