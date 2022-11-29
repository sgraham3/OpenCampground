class Extra < ActiveRecord::Base
  STANDARD = 0
  COUNTED = 1
  MEASURED = 2
  OCCASIONAL = 3
  DEPOSIT = 4

  has_many :extra_charges
  has_many :reservations, :through => :extra_charges
  has_and_belongs_to_many :taxrates
  acts_as_list
  validates_presence_of :name
  validates_uniqueness_of :name

  default_scope :order => :position
  named_scope :active, :conditions => ["active = ?", true], :order => "position"

  # a virtual method for subtotal
  def subtotal
    @subtotal
  end

  def subtotal=(st)
    @subtotal = st
  end

  def type_name
    case extra_type 
    when STANDARD
      return 'Standard'
    when COUNTED
      return 'Counted'
    when MEASURED
      return 'Metered'
    when OCCASIONAL
      return 'Occasional'
    when DEPOSIT
      return 'Deposit'
    end
  end


  def before_save
    self.daily = self.daily.to_f
    self.weekly = self.weekly.to_f
    self.monthly = self.monthly.to_f
    self.charge = self.charge.to_f
    self.rate = self.rate.to_f
  end

  def self.for_remote
    all :conditions => ["remote_display = ? AND extra_type != ? AND active = ?", true, MEASURED, true]
  end

end
