class Link < ActiveRecord::Migration
  def self.up
    add_column :reservations, :next,	:integer, :default => nil
    add_column :reservations, :prev,	:integer, :default => nil
    add_column :options, :use_links,	:boolean, :default => false
  end

  def self.down
    remove_column :reservations, :next
    remove_column :reservations, :prev
    remove_column :options, :use_links
  end
end
