class SimplifyPayments < ActiveRecord::Migration
  
  def self.up
    add_column :integrations, :use_pmt_dropdown, :boolean, :default => false
  end

  def self.down
    remove_column :integrations, :use_pmt_dropdown
  end

end
