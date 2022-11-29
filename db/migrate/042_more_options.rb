class MoreOptions < ActiveRecord::Migration
  def self.up
    add_column :options, :use_rig_age, :boolean, :default => true
    add_column :options, :use_length, :boolean, :default => true
    add_column :options, :disp_site_length, :boolean, :default => true
    add_column :options, :use_rig_type, :boolean, :default => true
    add_column :options, :use_slides, :boolean, :default => true
    add_column :options, :use_adults, :boolean, :default => true
    add_column :options, :use_children, :boolean, :default => true
    add_column :options, :use_pets, :boolean, :default => true
    add_column :options, :use_remote_age, :boolean, :default => true
    add_column :options, :use_remote_length, :boolean, :default => true
    add_column :options, :disp_remote_length, :boolean, :default => true
    add_column :options, :use_remote_rig_type, :boolean, :default => true
    add_column :options, :use_remote_slides, :boolean, :default => true
    add_column :options, :use_remote_adults, :boolean, :default => true
    add_column :options, :use_remote_children, :boolean, :default => true
    add_column :options, :use_remote_pets, :boolean, :default => true
    add_column :options, :inline_subtotal, :boolean, :default => false
  end

  def self.down
    remove_column :options, :use_rig_age
    remove_column :options, :use_length
    remove_column :options, :disp_site_length
    remove_column :options, :use_rig_type
    remove_column :options, :use_slides
    remove_column :options, :use_adults
    remove_column :options, :use_children
    remove_column :options, :use_pets
    remove_column :options, :use_remote_age
    remove_column :options, :use_remote_length
    remove_column :options, :disp_remote_length
    remove_column :options, :use_remote_rig_type
    remove_column :options, :use_remote_slides
    remove_column :options, :use_remote_adults
    remove_column :options, :use_remote_children
    remove_column :options, :use_remote_pets
    remove_column :options, :inline_subtotal
  end
end
