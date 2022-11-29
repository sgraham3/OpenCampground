class EnhanceDiscounts2 < ActiveRecord::Migration
  #############################################
  # enhance discounts 
  #   on all amount discounts
  #     lenth of application, d,w,m
  #     delay in application, d,w,m
  #############################################
  def self.up
    add_column :discounts, :duration, :integer, :default => 0
    add_column :discounts, :duration_units, :integer, :default => Discount::DAY
    add_column :discounts, :delay, :integer, :default => 0
    add_column :discounts, :delay_units, :integer, :default => Discount::DAY
    #
    # days... compare to day.strftime("%A").downcase
    # days discount applies
    add_column :discounts, :sunday, :boolean, :default => true
    add_column :discounts, :monday, :boolean, :default => true
    add_column :discounts, :tuesday, :boolean, :default => true
    add_column :discounts, :wednesday, :boolean, :default => true
    add_column :discounts, :thursday, :boolean, :default => true
    add_column :discounts, :friday, :boolean, :default => true
    add_column :discounts, :saturday, :boolean, :default => true
  end

  def self.down
    remove_column :discounts, :duration
    remove_column :discounts, :duration_units
    remove_column :discounts, :delay
    remove_column :discounts, :delay_units
    remove_column :discounts, :sunday
    remove_column :discounts, :monday
    remove_column :discounts, :tuesday
    remove_column :discounts, :wednesday
    remove_column :discounts, :thursday
    remove_column :discounts, :friday
    remove_column :discounts, :saturday
  end
end
