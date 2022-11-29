class RemoveBlanks < ActiveRecord::Migration
  def self.up
    # remove blanks from start and end of last names
    Camper.all.each {|c| c.update_attributes :last_name => c.last_name.strip }
  rescue
  end

  def self.down
  end
end
