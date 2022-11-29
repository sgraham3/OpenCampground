class UpdatePaypal < ActiveRecord::Migration
  #############################################
  # changes to support PayPal in the office
  #############################################
  def self.up
    create_table :paypal_transactions do |t|
      t.decimal :amount, :precision => 12, :scale => 2, :default => 0.0
      t.integer :reservation_id
      t.integer :payment_id
      t.string  :encrypted
      t.string  :url
      t.timestamps
    end
    add_index  :paypal_transactions, :reservation_id

    int = Integration.first
    if int.name == 'PayPal'
      int.update_attributes :name => 'PayPal_r'
    end
  end

  def self.down
    drop_table :paypal_transactions
    int = Integration.first
    if int.name == 'PayPal_r'
      int.update_attributes :name => 'PayPal'
    end
  end
end
