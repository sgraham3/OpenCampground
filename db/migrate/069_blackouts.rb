class Blackouts < ActiveRecord::Migration
  def self.up
    create_table :blackouts do |t|
      t.string :name, :limit => 32
      t.date :startdate
      t.date :enddate
      t.boolean :active, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :blackouts
  end
end
