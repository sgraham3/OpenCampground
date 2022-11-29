class Admin < ActiveRecord::Migration
  def self.up
    # use override_by_all already defined
    # add_column :options, :all_override_charges, :boolean, :default => false
    add_column :options, :all_onetime_discount, :boolean, :default => false
    add_column :options, :all_backup,           :boolean, :default => true
    add_column :options, :all_manage_backup,    :boolean, :default => false
    add_column :options, :all_manage_logs,      :boolean, :default => false
    add_column :options, :all_manage_payments,  :boolean, :default => false
    add_column :options, :all_manage_measured,  :boolean, :default => false
    add_column :options, :all_checkin_rpt,      :boolean, :default => true
    add_column :options, :all_leave_rpt,        :boolean, :default => true
    add_column :options, :all_arrival_rpt,      :boolean, :default => true
    add_column :options, :all_departure_rpt,    :boolean, :default => true
    add_column :options, :all_in_park_rpt,      :boolean, :default => true
    add_column :options, :all_space_sum_rpt,    :boolean, :default => true
    add_column :options, :all_occupancy_rpt,    :boolean, :default => false
    add_column :options, :all_campers_rpt,      :boolean, :default => false
    add_column :options, :all_transactions_rpt, :boolean, :default => false
    add_column :options, :all_payments_rpt,     :boolean, :default => false
    add_column :options, :all_measured_rpt,     :boolean, :default => false
    add_column :options, :all_recommend_rpt,    :boolean, :default => false
    add_column :options, :all_archives,         :boolean, :default => false
    add_column :options, :all_updates,          :boolean, :default => false
  end

  def self.down
    # remove_column :options, :all_override_charges
    remove_column :options, :all_onetime_discount
    remove_column :options, :all_backup
    remove_column :options, :all_manage_backup
    remove_column :options, :all_manage_logs
    remove_column :options, :all_manage_payments
    remove_column :options, :all_manage_measured
    remove_column :options, :all_checkin_rpt
    remove_column :options, :all_leave_rpt
    remove_column :options, :all_arrival_rpt
    remove_column :options, :all_departure_rpt
    remove_column :options, :all_in_park_rpt
    remove_column :options, :all_space_sum_rpt
    remove_column :options, :all_occupancy_rpt
    remove_column :options, :all_campers_rpt
    remove_column :options, :all_transactions_rpt
    remove_column :options, :all_payments_rpt
    remove_column :options, :all_measured_rpt
    remove_column :options, :all_recommend_rpt
    remove_column :options, :all_archives
    remove_column :options, :all_updates
  end
end
