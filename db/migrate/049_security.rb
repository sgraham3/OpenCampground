class Security < ActiveRecord::Migration
  def self.up
    add_column :options, :cookie_token,	:string
    add_column :options, :session_token,:string
  end

  def self.down
    remove_column :options, :cookie_token
    remove_column :options, :session_token
  end
end
