class Country < ActiveRecord::Base
  has_many :campers
  validates_uniqueness_of :name
  acts_as_list
  default_scope :order => :position
  named_scope :active, :conditions => ["active = ?", true]
end
