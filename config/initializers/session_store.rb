# Be sure to restart your server when you modify this file.

# make session key a constant so we can refer to it
SESSION_KEY = 'OpenCampground_session'

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
begin
  opt = Option.first
  ActionController::Base.session = {
    :key         => SESSION_KEY,
    :secret      => OC_VERSION + opt.session_token || OC_VERSION + 'SVBZ2rZyT4RMXl5JCb59ozoP+vNUwKRuF1PQFRBgccaa9mn4IHocorEqe9om4UITz7NoOWJoqNZEM4ks2sXM2w9ERQyq2ejcR4EDIQIBIwKCAQEA6sjUaqpfFC6nJQAy' 
  }
rescue
  ActionController::Base.session = {
    :key         => SESSION_KEY,
    :secret      => OC_VERSION + 'SVBZ2rZyT4RMXl5JCb59ozoP+vNUwKRuF1PQFRBgccaa9mn4IHocorEqe9om4UITz7NoOWJoqNZEM4ks2sXM2w9ERQyq2ejcR4EDIQIBIwKCAQEA6sjUaqpfFC6nJQAy' 
  }
end


# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
# ActionController::Base.session_store = :memory_store
