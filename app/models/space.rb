class Space < ActiveRecord::Base
  extend MyLib

  belongs_to :sitetype
  belongs_to :price
  has_many :reservations
  default_scope :order => :position
  acts_as_list
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_numericality_of :current
  before_validation :correct_length
  after_save :reset_sizes
  after_destroy :reset_sizes
  before_destroy :check_use

  named_scope :active, :conditions => ["active = ?", true]
  
  def ews
    t_string = ""
    if water?
      t_string += "W"
    end
    if sewer?
      t_string += "S"
    end
    if  power_50a?
      ews_string = "E" + t_string + " 50A"
    elsif power_30a?
      ews_string = "E" + t_string + " 30A"
    elsif power_15a?
      ews_string = "E" + t_string + " 15A"
    else
      ews_string = t_string
    end
  end

  def self.available(start_dt, end_dt, des_type=0, limit=0, offset=0, remote=false )
    ####################################################
    # given the parameters specified find all spaces not
    # already reserved that fit the spec
    # If start date of reservation is today make sure
    # the space is available.
    ####################################################

    cond_array = []
    conditions = 'active = ?'
    cond_array << true
    if remote
      conditions += ' AND remote_reservable = ?'
      cond_array << true
    end
    # ActiveRecord::Base.logger.debug "des_type is #{des_type.to_i}"
    unless des_type.to_i == 0
      conditions += ' AND sitetype_id = ?'
      cond_array << des_type.to_i
    end
    if start_dt == currentDate
      conditions += ' AND unavailable = ?'
      cond_array << false
    end
    conditions += ' AND id NOT IN (SELECT space_id FROM reservations WHERE archived = ? AND enddate > ? AND startdate < ? )'
    cond_array << false
    cond_array << start_dt
    cond_array << end_dt

    if limit > 0
      conditions += ' LIMIT ?'
      cond_array << limit
      if offset > 0
	conditions += ', ?'
	cond_array << offset
      end
    end
    all_spaces = all :conditions => [conditions,*cond_array], :order => :position, :include => ['sitetype', 'price']
  end
  
  def self.available_remote(start_dt, end_dt, des_type=0, limit=0, offset=0 )
    ####################################################
    # given the parameters specified find all spaces not
    # already reserved that fit the spec
    # If start date of reservation is today make sure
    # the space is available.
    ####################################################

    self.available(start_dt, end_dt, des_type, limit, offset, true )
  end

  def self.confirm_available(res_id, space_id, startdate, enddate)
    #######################################
    # confirm that this site is available on the dates specified
    #######################################
    Reservation.all(:conditions => ["archived = ? AND id != ? AND space_id = ?  AND enddate > ? AND startdate < ?",
				      false, res_id, space_id, startdate, enddate])
  end

  def occupied
    #######################################
    # check if this space is currently occupied
    #######################################
    Reservation.find_by_space_id_and_checked_in_and_archived!( id, true, false)
  rescue
    false
  end

private

  def check_use
    res = Reservation.find_all_by_space_id id
    if res.size > 0
      lst = ''
      res.each {|r| lst << " #{r.id},"}
      errors.add "space in use by reservation(s) #{lst}"
      return false
    end
  end

  def reset_sizes
    #######################################
    # recompute max_spacename by iterating
    # through all of the spaces.
    # needed when a space is deleted
    # or edited
    #######################################
    option = Option.first
    max = 0
    Space.all.each do |i|
      max = i.name.size unless max >= i.name.size 
    end
    option.update_attributes :max_spacename => max if max != option.max_spacename
  end

  def correct_length
    self.length ||= '0'
  end

end
