class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :hashed_password
      t.string :salt
      t.boolean :admin, :default => false # user has admin powers

      t.timestamps
    end
    User.create :name => 'manager', :password => 'secret', :password_confirmation => 'secret', :admin => true
    add_column "options", "use_login", :boolean, :default => false
    add_column "options", "use_remote_res", :boolean, :default => false
    add_column "reservations", "unconfirmed_remote", :boolean, :default => false
    Option.reset_column_information
    Reservation.reset_column_information
    Reservation.find(:all).each do |r|
      r.update_attribute :unconfirmed_remote, false
    end
  end

  def self.down
    drop_table :users
    remove_column "options", "use_login"
    remove_column "options", "use_remote_res"
    remove_column "reservations", "unconfirmed_remote"
  end
end
