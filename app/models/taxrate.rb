class Taxrate < ActiveRecord::Base
  include MyLib
  has_and_belongs_to_many :extras
  has_and_belongs_to_many :sitetypes
  has_and_belongs_to_many :variable_charges
  validate :valid_rate?
  validates_presence_of :name
  validates_uniqueness_of :name
  acts_as_list
  default_scope :order => :position
  named_scope :active, :conditions => ["active = ?", true]

  def self.calculate_tax (res_id, options)
    ###########################################
    # calculate taxes for given reservation
    ###########################################
    ###########################################
    # get the reservation info
    ###########################################
    res = Reservation.find res_id
    ###########################################
    # get the charge info
    ###########################################
    charges = Charge.find_all_by_reservation_id(res_id)
    ###########################################
    # get the extra info
    ###########################################
    extra_charges = ExtraCharge.find_all_by_reservation_id(res_id)
    ###########################################
    # get the variable info
    ###########################################
    variable_charges = VariableCharge.find_all_by_reservation_id(res_id)
    ###########################################
    # get the tax info
    ###########################################
    taxes = active
    ###########################################
    # delete the old tax records
    ###########################################
    Tax.destroy_all(["reservation_id = ?", res_id])
    ###########################################
    # go through the charges calculating tax
    # for each
    ###########################################
    tax_total = 0.0
    taxes.each do |tax|
      next unless res.space.sitetype.taxrates.exists?(tax)
      count = 0
      tax_amount = 0.0
      if tax.is_percent?
	taxable = 0.0
	charges.each do |ch|
	  if ((ch.charge_units == Charge::DAY && tax.apl_daily) ||
              (ch.charge_units == Charge::WEEK && tax.apl_week) ||
              (ch.charge_units == Charge::MONTH && tax.apl_month) ||
	      (ch.charge_units == Charge::SEASON && tax.apl_seasonal))
	    taxable += ch.amount - ch.discount
	  end
	end
	taxable -= res.onetime_discount
	tax_amount = tax.round_cents(tax.percent/100.0 * taxable ) if taxable > 0.0
      else 
	charges.each do |ch|
	  if ((ch.charge_units == Charge::DAY && tax.apl_daily) ||
              (ch.charge_units == Charge::WEEK && tax.apl_week) ||
              (ch.charge_units == Charge::MONTH && tax.apl_month) ||
	      (ch.charge_units == Charge::SEASON && tax.apl_seasonal))
	    count += (ch.end_date - ch.start_date).to_i
	  end
	end
	tax_amount = tax.round_cents(count * tax.amount)
      end
      if tax.is_percent?
	t = Tax.create( :reservation_id => res.id,
			:name => tax.name,
			:rate => tax.percent.to_s + "%",
			:amount => tax_amount) if tax_amount > 0.0
      else
	t = Tax.create( :reservation_id => res.id,
			:name => tax.name,
			:count => count.to_i,
			:rate => tax.number_2_currency(tax.amount) + " per night",
			:amount => tax_amount) if tax_amount > 0.0
      end
      tax_total += tax_amount
    end
    # calculate taxes for extras
    taxes.each do |tax|
      extra_charges.each do |ex|
	if ex.extra.taxrates.exists?(tax.id)
	  if tax.is_percent?
	    ActiveRecord::Base.logger.debug 'tax is percent'
	    charges = ex.charge + ex.monthly_charges + ex.weekly_charges + ex.daily_charges
	    if charges > 0.0
	      tax_amount = tax.round_cents(tax.percent/100.0 * charges)
	      ActiveRecord::Base.logger.debug "charges are #{ex.charge + ex.monthly_charges + ex.weekly_charges + ex.daily_charges}, rate is #{tax.percent} and amount is #{tax_amount}"
	      t = Tax.create( :reservation_id => res.id,
			      :name => tax.name,
			      :rate => tax.percent.to_s + "%",
			      :amount => tax_amount) if tax_amount > 0.0
	      tax_total += tax_amount
	    end
	  end
	end
      end
    end
    # calculate taxes for variable charges
    taxes.each do |tax|
      variable_charges.each do |var|
        if var.taxrates.exists?(tax.id) && tax.is_percent? && var.amount != 0.0
	  ActiveRecord::Base.logger.debug "#{tax.name} applies and is percent"
	  tax_amount = tax.round_cents(tax.percent/100.0 * var.amount)
	  t = Tax.create( :reservation_id => res.id,
			  :name => tax.name,
			  :rate => tax.percent.to_s + "%",
			  :amount => tax_amount) if tax_amount != 0.0
	  tax_total += tax_amount
	end
      end
    end
    Tax.combine(res.id)
    return tax_total
  end

private

  def valid_rate?
    if is_percent?
      if percent.nil? || percent <= 0.0
        errors.add(:percent, "is missing or invalid")
      end
    else
      if amount.nil? || amount <= 0.0
        errors.add(:amount, "is missing or invalid")
      end
    end
  end

end
