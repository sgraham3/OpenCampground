class Integration < ActiveRecord::Base
  before_save :check_record

  def check_record
    self.cc_merchant_id = self.cc_merchant_id.strip if self.cc_merchant_id_changed?
    self.cc_api_username = self.cc_api_username.strip if self.cc_api_username_changed?
    self.cc_api_password = self.cc_api_password.strip if self.cc_api_password_changed?
    if self.name.start_with? 'PayPal'
      # ActiveRecord::Base.logger.debug 'Integration#before_save PayPal'
      unless File.exist? Rails.root.join('config', 'paypal', 'my-prvkey.pem')
        errors.add :pp_cert_id, 'required private key is missing, see User Manual, appendix F'
      end
    end
  rescue
  end

  def cc_gateway
    if Rails.env.production?
      'https://boltgw.cardconnect.com:8443'
    else
      'https://boltgw.cardconnect.com:6443'
    end
  end

  def self.first_or_create(attributes = nil, &block)
    first || create(attributes, &block)
  end

  def self.terminal?
    first.cc_bolt_api_key.size > 0
  end

  def self.no_terminal?
    first.cc_bolt_api_key.size == 0
  end

end
