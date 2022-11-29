class RemoteManditory < ActiveRecord::Migration
  def self.up
    add_column :options, :require_first, :boolean, :default => false
    add_column :options, :require_addr, :boolean, :default => false
    add_column :options, :require_city, :boolean, :default => false
    add_column :options, :require_state, :boolean, :default => false
    add_column :options, :require_mailcode, :boolean, :default => false
    add_column :options, :require_country, :boolean, :default => false
    add_column :options, :require_id, :boolean, :default => false
  end

  def self.down
    remove_column :options, :require_first
    remove_column :options, :require_addr
    remove_column :options, :require_city
    remove_column :options, :require_state
    remove_column :options, :require_mailcode
    remove_column :options, :require_country
    remove_column :options, :require_id
  end

end
