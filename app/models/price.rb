class Price < ActiveRecord::Base
  has_many :spaces
  has_many :rates
  has_many :seasons, :through => :rates
  validates_presence_of :name
  validates_uniqueness_of :name
  before_destroy :clean_up

  def clean_up
    ActiveRecord::Base.logger.debug "cleaning up from deletion of price #{name}"
    Rate.all(:conditions => ["price_id = ?", id]).each do |r|
      ActiveRecord::Base.logger.debug "destroying rate #{r.id}"
      r.destroy
    end
  end
end
