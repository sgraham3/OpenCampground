class Email < ActiveRecord::Base
  belongs_to :smtp_authentication

  def self.address_valid?(address)
    ##########################################
    # is this email address a valid syntax?
    # no checking on whether or not it really
    # is valid or in a valid domain
    ##########################################
    return false if address.nil?
    name,at,host = address.partition('@')
    return false if name.empty?
    return false if at.empty?
    return false if host.empty?
    return true
  end

end
