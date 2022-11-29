class UpdateColors < ActiveRecord::Migration
  def self.up
    Color.create!(:name => 'unavailable_background', :value => 'Red')
    Color.create!(:name => 'this_day_background', :value => 'lightGreen')
  end

  def self.down
  end
end
