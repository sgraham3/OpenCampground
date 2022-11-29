class Blackout < ActiveRecord::Base
  validate :valid_dates?
  validates_presence_of     :name
  validates_uniqueness_of   :name
  named_scope :active, :conditions => ["active = ?", true]
  default_scope :order => :startdate
  
  def self.available(sd, ed)
    ActiveRecord::Base.logger.debug "checking sd of #{sd} and ed of #{ed}"
    avail = sd
    ActiveRecord::Base.logger.debug "avail1 = #{avail}"
    self.active.each do |b|
      ActiveRecord::Base.logger.debug "checking #{b.name}"
      ActiveRecord::Base.logger.debug "blackout startdate is #{b.startdate} and enddate is #{b.enddate}"
      # dt = b.blacked_out?(sd, ed)
      # if dt && dt > avail
      if b.blacked_out?(sd, ed)
	avail = b.enddate + 1
	ActiveRecord::Base.logger.debug "blacked out and avail2 = #{avail}"
      end
      ActiveRecord::Base.logger.debug "avail2 = #{avail}"
    end
    ActiveRecord::Base.logger.debug "avail final = #{avail}"
    avail
  end

  def blacked_out?(sd, ed)
    ActiveRecord::Base.logger.debug "Blackout#blacked_out?: startdate = #{self.startdate} sd = #{sd}, enddate = #{enddate} ed = #{ed}"
    return false unless active
    return false if sd > self.enddate || ed < self.startdate
    return true if sd <= self.enddate && ed > self.startdate
    ActiveRecord::Base.logger.debug "condition not found"
    return false
  end

private
  def valid_dates?
    if enddate < startdate
      errors.add :startdate, "is after enddate"
    end
  end
end
