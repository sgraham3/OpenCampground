class Available < ActiveRecord::Migration
  def self.up
    add_column :options, :show_available,        :boolean, :default => true
    add_column :options, :show_remote_available, :boolean, :default => true
    add_column :reservations, :updated_at, :datetime
    add_column :reservations, :sitetype_id, :integer, :default => 0
    Reservation.all.each {|r| r.update_attribute(:updated_at, r.updated_on)}
  end

  def self.down
    remove_column :options, :show_available
    remove_column :options, :show_remote_available
    remove_column :reservations, :updated_at
    remove_column :reservations, :sitetype_id
  end
end
