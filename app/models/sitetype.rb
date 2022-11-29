class Sitetype < ActiveRecord::Base
  has_many :spaces
  has_many :reservations, :through => :spaces
  has_and_belongs_to_many :taxrates
  validates_presence_of :name
  validates_uniqueness_of :name
  acts_as_list
  default_scope :order => :position
  named_scope :active, :conditions => ["active = ?", true]
  before_destroy :check_use

  private

  def check_use
    sp = Space.find_all_by_sitetype_id id
    if sp.size > 0
      lst = ''
      sp.each {|s| lst << " #{s.id},"}
      errors.add "sitetype in use by space(s) #{lst}"
      return false
    end
  end

end
