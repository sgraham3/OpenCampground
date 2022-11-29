class LocalManditory < ActiveRecord::Migration
  def self.up
    add_column :options, :l_require_first, :boolean, :default => false
    add_column :options, :l_require_addr, :boolean, :default => false
    add_column :options, :l_require_city, :boolean, :default => false
    add_column :options, :l_require_state, :boolean, :default => false
    add_column :options, :l_require_mailcode, :boolean, :default => false
    add_column :options, :l_require_country, :boolean, :default => false
    add_column :options, :l_require_id, :boolean, :default => false
    add_column :options, :l_require_phone, :boolean, :default => false
    add_column :options, :l_require_email, :boolean, :default => false
  end

  def self.down
    remove_column :options, :l_require_first
    remove_column :options, :l_require_addr
    remove_column :options, :l_require_city
    remove_column :options, :l_require_state
    remove_column :options, :l_require_mailcode
    remove_column :options, :l_require_country
    remove_column :options, :l_require_id
    remove_column :options, :l_require_phone
    remove_column :options, :l_require_email
  end

end
