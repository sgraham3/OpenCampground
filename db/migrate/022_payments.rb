class Payments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.decimal :amount, :precision => 8, :scale => 2, :default => 0.0
      t.integer :reservation_id

      t.timestamps
    end

    Reservation.find(:all, :conditions => "deposit > 0.0").each do |r|
      Payment.create :amount => r.deposit, :reservation_id => r.id
    end
    add_index :payments, :reservation_id

  end

  def self.down
    drop_table :payments
  end
end
