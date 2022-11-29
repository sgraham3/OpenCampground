class AddCallHome < ActiveRecord::Migration
  
  def self.up
    add_column :options, :phone_home, :string
  end

  def self.down
    remove_column :options, :phone_home
  end

end
