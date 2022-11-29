class Group < ActiveRecord::Base
  has_many :reservations
  belongs_to :camper
  validates_uniqueness_of :name
  validates_presence_of :name
  validates_presence_of :startdate
  validates_presence_of :enddate
  before_destroy :check_use
  before_save :check_camper
  
  default_scope :order => "name asc"

  def self.count_by_group(id)
    Reservation.find_all_by_group_id(id.to_i).size
  end
  
  private

  def check_use
    res = Reservation.find_all_by_group_id(id)
    ActiveRecord::Base.logger.debug "found #{res.size} reservations"
    res.each do |r|
      ActiveRecord::Base.logger.debug "found #{r.id}"
      ActiveRecord::Base.logger.debug "group is #{r.group.name}"
      r.update_attributes :group_id => 0
      r.add_log("group #{self.name} destroyed")
    end
  end

  def check_camper
    self.camper_id ||= Camper.first.id
  rescue
    self.camper_id = Camper.create :last_name => 'dummy'
  end

end
