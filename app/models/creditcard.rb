class Creditcard < ActiveRecord::Base
  has_many :reservations
  validates_presence_of :name
  validates_uniqueness_of :name
  acts_as_list
  default_scope :order => :position
  named_scope :active, :conditions => ["active = ?", true]

  #################################################
  # get the type of card from the cardconnect token
  #################################################
  def self.card_type(number)
    case number
    when '3'
      # AMEX
      'Amex'
    when '4'
      # VISA,
      'Visa'
    when '2','5'
      # MC
      'Mastercard'
    when '6'
      # Discover
      'Discover'
    else
      'Unrecognized'
    end
  end

  #################################################
  # given a card name come up with a normalized
  # name and if this card does not exist create it
  # return the card_id
  #################################################
  def self.id_by_name(name)
    ActiveRecord::Base.logger.debug "Creditcard#id_by_name name is #{name}"
    card_id = self.find_by_name(name.capitalize)
  rescue
    card_id = self.create(:name => name.capitalize) if card_id == nil
    ActiveRecord::Base.logger.debug "Creditcard#id_by_name card_id is #{card_id}"
  ensure
    card_id
  end

  #################################################
  # credit card number validation (Luhn algorithm)
  # posted on the internet by Wikipedia 
  #################################################
  def self.valid_credit_card?(number)
    return false unless number.is_a?(String)
    digits = number.scan(/\d/).map(&:to_i).reverse
    return false if digits.empty?
    check_digit = digits.shift
    final_digits = []
    digits.each_with_index do |value, index|
      if index.even?
	final_digits << (value * 2).to_s.split('').map(&:to_i)
      else
	final_digits << value
      end
    end
    (final_digits.flatten.inject(:+) + check_digit) % 10 == 0
  rescue
    # some error in validation. 
    # Must not be valid
    return false
  end

  def card_expired?(exp_date)
    if validate_expiration
      exp_date.past?
    else
      false
    end
  rescue
    # some error in validation. 
    # Must be expired
    return true
  end

end
