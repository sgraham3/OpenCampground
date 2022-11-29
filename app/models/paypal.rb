class Paypal

attr_accessor :check_keyfile
attr_accessor :create_keyfile
attr_accessor :country
attr_accessor :state
attr_accessor :city
attr_accessor :name
attr_accessor :servername
attr_accessor :email

# Keyfile = Rails.root.join('config','paypal','my-prvkey.pem').to_s
# Certfile = Rails.root.join('config','paypal','my-pubcert.pem').to_s
# Configfile = Rails.root.join('tmp','config').to_s
# Randfile = Rails.root.join('tmp','rand').to_s
Keyfile = 'config/paypal/my-prvkey.pem'
Certfile = 'config/paypal/my-pubcert.pem'
Configfile = 'tmp/config'
Randfile = 'tmp/rand'

################################################
# Create keyfile and certfile
#
# keyfile goes in config/paypal
# certfile is copied to config/paypal and then
# downloaded so user can put it in their PayPal account
################################################

  def generate_p_key
    # if Keyfile exists rename it to Keyfile.bak
    if File.exists? Keyfile
      File.rename Keyfile, Keyfile + '.bak'
    end
    # generate the key file
    status = system "openssl rand -out #{Randfile} 1024"
    status = system "openssl genrsa -rand #{Randfile} -writerand #{Randfile} -out #{Keyfile} 2048"
    if status
      return true
    else
      Rails.logger.debug "keyfile generation returned #{$?}"
      return false
    end
  rescue => err
    Rails.logger.debug "generate_p_key status #{err}"
  end

  def generate_p_cert
    # if Certfile exists delete it
    if File.exists? Certfile
      File.delete Certfile
    end
    # generate_config_file
    generate_config_file
    # generate the cert file
    status = system "openssl req -x509 -batch -new -config #{Configfile} -key #{Keyfile} -days 3650 -out #{Certfile}"
    if status
      return true
    else
      Rails.logger.debug "certificate generation returned #{$?}"
      return false
    end
  rescue => err
    Rails.logger.debug "generate_p_cert status #{err}"
  ensure
    File.delete Configfile if File.exists? Configfile
  end

  private

  def initialize args = {}
    args.each do |k,v|
      # Rails.logger.debug "key: #{k}, value: #{v}"
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def generate_config_file
    # C = US, ST = Kansas, L = Topeka, O = My Campground, CN = my_campground.ocsrv.net, emailAddress = abc@def
    fd = File.new Configfile, "w"
    fd.write "[ req ]\n"
    fd.write "default_bits = 2048\n"
    fd.write "distinguished_name = req_distinguished_name\n"
    fd.write "x509_extensions = v3_ca\n"
    fd.write "prompt = no\n\n"
    fd.write "[req_distinguished_name]\n"
    fd.write "countryName = #{country}\n"
    fd.write "stateOrProvinceName = #{state}\n"
    fd.write "localityName = #{city}\n"
    fd.write "organizationName = #{name}\n"
    fd.write "organizationalUnitName  = campground\n"
    fd.write "commonName = #{servername}\n"
    fd.write "[v3_ca]\n"
    fd.write "subjectKeyIdentifier = hash\n"
    fd.write "authorityKeyIdentifier = keyid\n"
    fd.write "basicConstraints = critical, CA:TRUE\n\n"
    fd.close
  end

end
