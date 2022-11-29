class VariableCharge < ActiveRecord::Base
  belongs_to :reservation
  has_and_belongs_to_many :taxrates
  attr_accessor :variable_charge
  after_save :update_reservation
  before_destroy :destroy_var

  def self.charges(id)
    var = self.find_all_by_reservation_id(id)
    var_charges = 0.0
    var.each { |v| var_charges += v.amount }
    return var_charges
  end

  private
  def update_reservation
    # update total in reservation to reflect the changes
    # from this charge
    ActiveRecord::Base.logger.debug "initial value = #{self.amount_was}, new value = #{self.amount}"
    res = Reservation.find reservation_id
    tax = 0.0
    Taxrate.active.each do |t|
      # compute tax
      tax += (self.amount - self.amount_was) * t.percent/100.0 if t.is_percent && self.taxrates.exists?(t)
    end
    res.update_attributes :total => res.total + self.amount - self.amount_was + tax
    Taxrate.calculate_tax(res.id, Option.first)
  end

  def destroy_var
    # update total in reservation to reflect the changes
    # that were in the charge being deleted
    ActiveRecord::Base.logger.debug "initial value = #{self.amount_was}"
    res = Reservation.find reservation_id
    tax = 0.0
    Taxrate.active.each do |t|
      # compute tax
      tax += self.amount * t.percent/100.0 if t.is_percent && self.taxrates.exists?(t)
    end
    res.update_attributes :total => res.total - self.amount + tax
  end

end
