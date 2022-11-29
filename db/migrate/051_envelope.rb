class Envelope < ActiveRecord::Migration
  def self.up
    add_column :options, :use_envelope, :boolean, :default => false
    add_column :options, :margin_top, :string, :default => '0.5in'
    add_column :options, :margin_left, :string, :default => '0.56in'
    add_column :options, :margin_bottom, :string, :default => '0.5in'
  end

  def self.down
    remove_column :options, :use_envelope
    remove_column :options, :margin_top
    remove_column :options, :margin_left
    remove_column :options, :margin_bottom
  end
end
