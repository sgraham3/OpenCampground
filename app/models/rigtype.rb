class Rigtype < ActiveRecord::Base
  has_many :reservations
  validates_presence_of :name
  validates_uniqueness_of :name
  before_destroy :check_use
  acts_as_list

  default_scope :order => :position
  named_scope :active, :conditions => ["active = ?", true]

  private

  def check_use
    res = Reservation.find_all_by_rigtype_id id
    if res.size > 0
      lst = ''
      res.each {|r| lst << " #{r.id},"}
      errors.add "rigtype in use by reservation(s) #{lst}"
      return false
    end
  end
end
