module CryptoOC
  class Button
    def initialize(data)
      my_cert_file = Rails.root.join('config','paypal','my-pubcert.pem')
      my_key_file = Rails.root.join('config','paypal','my-prvkey.pem')
      if Rails.env.production?
	paypal_cert_file = Rails.root.join('config','paypal','paypal_cert.pem')
      else
	paypal_cert_file = Rails.root.join('config','paypal','sandbox_cert.pem')
      end

      IO.popen("/usr/bin/openssl smime -sign -signer #{my_cert_file} -inkey #{my_key_file} -outform der -nodetach -binary | /usr/bin/openssl smime -encrypt -des3 -binary -outform pem #{paypal_cert_file}", 'r+') do |pipe|
	data.each { |x,y| pipe << "#{x}=#{y}\n" }
	pipe.close_write
	@data = pipe.read
      end
    end

    def self.from_hash(hs)
      self.new hs
    end

    def get_encrypted_text
      return @data
    end

  end #end button
end #end module
