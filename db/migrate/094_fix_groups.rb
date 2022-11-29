class FixGroups < ActiveRecord::Migration
  class Group < ActiveRecord::Base;end
  
  def self.up
    Group.all.each do |grp|
      # fix group expected number
      count = Reservation.count :conditions => "group_id = #{grp.id}"
      grp.update_attributes :expected_number => count
    end
  end

  def self.down
  end

end
