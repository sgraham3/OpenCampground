# Be sure to restart your server when you modify this file.

begin
  opt = Option.first
  if opt.use_confirm_email == true
    email = Email.first
    # smtp only for now
    ActionMailer::Base.delivery_method = :smtp
    # other possibilities are :sendmail and :test
    if email.smtp_authentication.name == 'none'
      ActionMailer::Base.smtp_settings = {
	:address => email.smtp_address,
	:port => email.smtp_port,
	:domain => email.smtp_domain,
	# :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
	:enable_starttls_auto => true
      }
    else
      ActionMailer::Base.smtp_settings = {
	:address => email.smtp_address,
	:port => email.smtp_port,
	:domain => email.smtp_domain,
	:authentication => email.smtp_authentication.name.to_sym,
	:user_name => email.smtp_username,
	:password => email.smtp_password,
	# :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
	:enable_starttls_auto => true
      }
    end
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.raise_delivery_errors = true
    ActionMailer::Base.default_charset = email.charset
  end
rescue
end
