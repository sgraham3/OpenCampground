class Occupancy
  attr_reader :name, :month, :days

  def initialize( name , days, month) 
    @name = name
    @days = days
    @month = month
  end

  def days=(new_days)
    @days = new_days
  end

  def dump_occ
    "#{name} #{month} #{days} days"
  end

  def +(other)
    days + other.days
  end

  def ==(other)
    name == other.name && month == other.month
  end

  def gets(other)
    days = other.days
  end

end
