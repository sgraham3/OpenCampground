class AddExtras < ActiveRecord::Migration
  class Extra < ActiveRecord::Base; end
  class Rate < ActiveRecord::Base; end

  def self.up
    create_table "extras" do |t|
      t.column "name",    :string, :limit => 16
      t.column "counted", :boolean, :default => false
      t.column "daily",   :integer
      t.column "weekly",  :integer
      t.column "monthly", :integer
    end
    create_table "extra_charges" do |t|
      t.column "extra_id", :integer
      t.column "reservation_id", :integer
      t.column "count", :integer, :default => 0
      t.column "days", :integer, :default => 0
      t.column "weeks", :integer, :default => 0
      t.column "months", :integer, :default => 0
      t.column "daily_charges",   :integer, :default => 0
      t.column "weekly_charges",  :integer, :default => 0
      t.column "monthly_charges", :integer, :default => 0
    end

    add_column "archives", "extras", :string
    add_column "reservations","created_at", :timestamp
    add_column "reservations","ext_charges", :decimal, :precision => 6, :scale => 2, :default => 0.0

    add_index :extra_charges, :reservation_id
    add_index :extra_charges, :extra_id
    add_index :reservations, :startdate
    add_index :reservations, :enddate
    add_index :reservations, :group_id
    add_index :reservations, :space_id
    add_index :rates, :season_id
    add_index :rates, :price_id
    add_index :campers, :last_name
    Archive.reset_column_information
    Reservation.reset_column_information
  end

  def self.down
    drop_table "extras"
    drop_table "extra_charges"
    remove_column "archives", "extras"
    remove_column "reservations", "created_at"
    remove_column "reservations","ext_charges"
    remove_index :reservations, :startdate
    remove_index :reservations, :enddate
    remove_index :reservations, :group_id
    remove_index :reservations, :space_id
    remove_index :rates, :season_id
    remove_index :rates, :price_id
    remove_index :campers, :last_name
  end
end
