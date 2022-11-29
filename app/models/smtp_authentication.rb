class SmtpAuthentication < ActiveRecord::Base
  has_many :emails
end
