class RemoveCvv2 < ActiveRecord::Migration
  def self.up
   remove_column :payments, :cvv2
   remove_column :creditcards, :use_cvv2
   add_column :payments, :pmt_date, :date
   Payment.reset_column_information
   Payment.all.each {|p| p.update_attribute :pmt_date, p.created_at.to_date}
  end

  def self.down
   remove_column :payments, :pmt_date
   add_column :payments, :cvv2, :integer
   add_column :creditcards, :use_cvv2, :boolean
  end
end
