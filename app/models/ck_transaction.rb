class CkTransaction < ActiveRecord::Base
  # for CardKnox only
  # needs to be adapted to CardKnox api and ifields
  require 'time'
  require 'base64'
  require 'net/http'
  # require ActiveMerchant::Billing
  require 'active_merchant'
  include MyLib
  belongs_to :reservation
  belongs_to :payment

  attr_accessor :xCVV, :xCardNum, :expiry

  alias_attribute :xInvoice, :reservation_id
  alias_attribute :xAuthAmount, :amount
  alias_attribute :xCurrency, :currency
  alias_attribute :xResult, :result
  alias_attribute :xStatus, :status
  alias_attribute :xError, :error
  alias_attribute :xRefNum, :retref
  alias_attribute :xToken, :token
  alias_attribute :xBatch, :batchid
  alias_attribute :xMaskedCardNumber, :masked_card_num
  alias_attribute :xCardType, :card_brand

  TermCard = 1
  TermManual = 2
  TokenRemote = 3
  TokenLocal = 4
  BbPos = 5

  def respstat
    result
  end

  def xExp
    month + year
  end

  def xExp=(date)
    self.month = date.slice(0, 2)
    self.year = date.slice(2, 2)
  end

  def authorize
    # untested
    (ccard, _a, _b) = xCardNum.partition(';')
    card = ActiveMerchant::Billing::CreditCard.new(
      :number => xCardNum,
      :verification_value => xCVV,
      :month => month,
      :year => year
    )
    logger.debug "processing authorize for #{pennies}"
    response = gateway.authorize(pennies, card)
    if response.success?
      logger.debug "token is #{response.params['token']}, retref is #{response.params['ref_num']}"
      update_attributes :token => response.params["token"],
                        :amount => response.params["amount"],
                        :result => response.params["result"],
                        :status => response.params["status"],
                        :error => response.params["error"],
                        :authcode => response.params["auth_code"],
                        :retref => response.params["ref_num"],
                        :batchid => response.params["batch"],
                        :avscode => response.params["avs_result_code"],
                        :avsresp => response.params["avs_result"],
                        :cvvcode => response.params["cvv_result_code"],
                        :cvvtext => response.params["cvv_result"],
                        :card_brand => cc_brand(ccard),
                        :masked_card_num => response.params["masked_card_num"]
      logger.debug "Successfully authorized $#{response.params['amount']} to the credit card #{response.params['masked_card_num']}"
      response
    else
      logger.debug "Status #{response.params['status']}, error msg #{response.params['error']}"
      logger.debug response.inspect
      raise StandardError, response.message
    end
  end

  def void_release
    # untested
    # for release of an authorize before it expires
  end

  def capture
    # untested
    # Capture the money
    logger.debug "processing capture for #{pennies}"
    response = gateway.capture(pennies, retref)
    if response.success?
      update_attributes :token => response.params["token"],
                        :amount => response.params["amount"],
                        :result => response.params["result"],
                        :status => response.params["status"],
                        :error => response.params["error"],
                        :authcode => response.params["auth_code"],
                        :retref => response.params["ref_num"],
                        :batchid => response.params["batch"]
      logger.debug "Successfully captured $#{response.params['amount']}"
      response
    else
      logger.debug "Status #{response.params['status']}, error msg #{response.params['error']}"
      logger.debug response.inspect
      raise StandardError, response.message
    end
  end

  def purchase
    # logger.debug("card_sut = #{self.xCardNum}")
    # logger.debug("cvv_sut = #{self.xCVV}")
    raise StandardError, "Card expired #{month}/#{year}" if card_expired?

    number = token || xCardNum

    card = ActiveMerchant::Billing::CreditCard.new(
      :number => number,
      :verification_value => xCVV,
      :month => month,
      :year => year
    )
    # logger.debug "credit card is #{card.inspect}"
    logger.debug "processing charge for #{pennies}"
    # custom options dont seem to be working
    response = gateway.purchase(pennies, card, { :invoice => reservation_id,
                                                 :custom02 => 'purchase' })
    # logger.debug response.inspect
    # successful example
    # <ActiveMerchant::Billing::Response:0x00007f43786e5a88
    # @params={"result"=>"A",
    #	       "status"=>"Approved",
    #	       "error"=>"",
    #	       "auth_code"=>"33323A",
    #	       "ref_num"=>"567601140",
    #	       "token"=>"5p0m03m6917p7056n1g621q8q79p64p2",
    #	       "batch"=>"10755752",
    #	       "avs_result"=>"Address: No Match & 5 Digit Zip: No Match",
    #	       "avs_result_code"=>"NNN",
    #	       "cvv_result"=>"No Match",
    #	       "cvv_result_code"=>"N",
    #	       "amount"=>"0.28",
    #	       "masked_card_num"=>"4xxxxxxxxxxx2085"},
    # @message="Success",
    # @success=true,
    # @test=false,
    # @authorization="567601140;5p0m03m6917p7056n1g621q8q79p64p2;credit_card",
    # @fraud_review=nil,
    # @avs_result={"code"=>"NNN",
    #		   "message"=>nil,
    #		   "street_match"=>nil,
    #		   "postal_match"=>nil},
    # @cvv_result={"code"=>"N",
    #		    "message"=>"No Match"}>
    if response.success?
      logger.debug "token is #{response.params['token']}, retref is #{response.params['ref_num']}"
      update_attributes :token => response.params["token"],
                        :amount => response.params["amount"],
                        :result => response.params["result"],
                        :status => response.params["status"],
                        :error => response.params["error"],
                        :authcode => response.params["auth_code"],
                        :retref => response.params["ref_num"],
                        :batchid => response.params["batch"],
                        :avscode => response.params["avs_result_code"],
                        :avsresp => response.params["avs_result"],
                        :cvvcode => response.params["cvv_result_code"],
                        :cvvtext => response.params["cvv_result"],
                        :card_brand => brand_from_sut(xCardNum),
                        :masked_card_num => response.params["masked_card_num"]
      logger.debug "Successfully charged $#{response.params['amount']} to the credit card #{response.params['masked_card_num']}"
    else
      logger.debug "Status #{response.params['status']}, error msg #{response.params['error']}"
      # raise StandardError, response.message
    end
    logger.debug response.inspect
    response
  end

  def void_refund
    ################################
    # void or refund a charge
    # first try void then try refund
    ################################
    logger.debug 'void_refund'
    response = void
    return response if response

    logger.debug 'void failed, trying refund'
    refund
  end

  def void
    ################################
    # void a charge
    ################################
    logger.debug 'void'
    response = gateway.void(retref)
    update_attributes :token => response.params["token"],
                      :result => response.params["result"],
                      :status => response.params["status"],
                      :error => response.params["error"],
                      :authcode => response.params["auth_code"],
                      :retref => response.params["ref_num"],
                      :batchid => response.params["batch"]
    logger.debug response.inspect
    logger.debug "void success = #{response.success?}"
    response.success?
  end

  def refund
    ################################
    # refund a charge
    ################################
    logger.debug "refund #{pennies}"
    # response = gateway.refund(pennies, retref, purchase_options('refund'))
    response = gateway.refund(pennies, retref)
    update_attributes :token => response.params["token"],
                      :amount => response.params["amount"],
                      :result => response.params["result"],
                      :status => response.params["status"],
                      :error => response.params["error"],
                      :authcode => response.params["auth_code"],
                      :retref => response.params["ref_num"],
                      :batchid => response.params["batch"]
    logger.debug response.inspect
    logger.debug "success = #{response.success?}"
    response.success?
  end

  private

  def brand_from_sut(sut)
    start = sut =~ /_cc_/
    sut[start + 4, 4].capitalize
  end

  def cc_brand(card)
    card_companies.reject { |c, _p| c == 'maestro' }.each do |company, pattern|
      return company.dup if card =~ pattern
    end
    nil
  end

  def pennies
    (amount * 100).to_i
  end

  def key
    int = Integration.first
    int.ck_api
  end

  def gateway
    if Rails.env.production?
      # production is the default
      # ActiveMerchant::Billing::Base.mode = :production
    else
      logger.debug 'use test servers'
      ActiveMerchant::Billing::Base.mode = :test
    end
    ActiveMerchant::Billing::CardknoxGateway.new(:api_key => key)
  end

  def card_expired?
    logger.debug 'validating expiry'
    dt = Date.new year.to_i, month.to_i, 1
    logger.debug "dt is #{dt}"
    if dt.at_end_of_month < currentDate
      logger.debug 'bad date'
      true
    else
      logger.debug 'OK date'
      false
    end
  end

  def card_companies
    {
      'visa' => /^4\d{12}(\d{3})?$/,
      'master' => /^(5[1-5]\d{4}|677189)\d{10}$/,
      'discover' => /^(6011|65\d{2}|64[4-9]\d)\d{12}|(62\d{14})$/,
      'american_express' => /^3[47]\d{13}$/,
      'diners_club' => /^3(0[0-5]|[68]\d)\d{11}$/,
      'jcb' => /^35(28|29|[3-8]\d)\d{12}$/
    }
  end
end

module ActiveMerchant # :nodoc:
  module Billing # :nodoc:
    class CreditCard
      # Returns or sets the track data for the card
      # copied from 1.119
      # @return [String]
      attr_accessor :track_data

      # Returns or sets whether a card has been processed using manual entry.
      #
      # This attribute is optional and is only used by gateways who use this information in their transaction risk
      # calculations. See {this page on 'card not present' transactions}[http://en.wikipedia.org/wiki/Card_not_present_transaction]
      # for further explanation and examples of this kind of transaction.
      #
      # @return [true, false]
      attr_accessor :manual_entry
    end

    class CardknoxGateway < Gateway
      self.live_url = 'https://x1.cardknox.com/gateway'

      self.supported_countries = %w[US CA GB]
      self.default_currency = 'USD'
      self.supported_cardtypes = [:visa, :master, :american_express, :discover, :diners_club, :jcb]

      self.homepage_url = 'https://www.cardknox.com/'
      self.display_name = 'Cardknox'

      COMMANDS = {
        :credit_card => {
          :purchase => 'cc:sale',
          :authorization => 'cc:authonly',
          :capture => 'cc:capture',
          :refund => 'cc:refund',
          :void => 'cc:void',
          :save => 'cc:save'
        },
        :check => {
          :purchase => 'check:sale',
          :refund => 'check:refund',
          :void => 'check:void',
          :save => 'check:save'
        }
      }

      def initialize(options = {})
        requires!(options, :api_key)
        super
      end

      # There are three sources for doing a purchase transation:
      # - credit card
      # - check
      # - cardknox token, which is returned in the the authorization string "ref_num;token;command"

      def purchase(amount, source, options = {})
        post = {}
        add_amount(post, amount, options)
        add_invoice(post, options)
        add_source(post, source)
        add_address(post, source, options)
        add_customer_data(post, options)
        add_custom_fields(post, options)
        commit(:purchase, source_type(source), post)
      end

      def authorize(amount, source, options = {})
        post = {}
        add_amount(post, amount)
        add_invoice(post, options)
        add_source(post, source)
        add_address(post, source, options)
        add_customer_data(post, options)
        add_custom_fields(post, options)
        commit(:authorization, source_type(source), post)
      end

      def capture(amount, authorization, _options = {})
        post = {}
        add_reference(post, authorization)
        add_amount(post, amount)
        commit(:capture, source_type(authorization), post)
      end

      def refund(amount, authorization, _options = {})
        post = {}
        add_reference(post, authorization)
        add_amount(post, amount)
        commit(:refund, source_type(authorization), post)
      end

      def void(authorization, _options = {})
        post = {}
        add_reference(post, authorization)
        commit(:void, source_type(authorization), post)
      end

      def verify(credit_card, options = {})
        MultiResponse.run(:use_first_response) do |r|
          r.process { authorize(100, credit_card, options) }
          r.process(:ignore_result) { void(r.authorization, options) }
        end
      end

      def store(source, options = {})
        post = {}
        add_source(post, source)
        add_address(post, source, options)
        add_invoice(post, options)
        add_customer_data(post, options)
        add_custom_fields(post, options)
        commit(:save, source_type(source), post)
      end

      def supports_scrubbing?
        true
      end

      def scrub(transcript)
        transcript.
          gsub(/(xCardNum=)\d+/, '\1[FILTERED]').
          gsub(/(xCVV=)\d+/, '\1[FILTERED]').
          gsub(/(xAccount=)\d+/, '\1[FILTERED]').
          gsub(/(xRouting=)\d+/, '\1[FILTERED]').
          gsub(/(xKey=)\w+/, '\1[FILTERED]')
      end

      private

      def split_authorization(authorization)
        authorization.split(';')
      end

      def add_reference(post, reference)
        reference, = split_authorization(reference)
        post[:Refnum] = reference
      end

      def source_type(source)
        if source.respond_to?(:brand)
          :credit_card
        elsif source.respond_to?(:routing_number)
          :check
        elsif source.is_a?(String)
          source_type_from(source)
        else
          raise ArgumentError, "Unknown source #{source.inspect}"
        end
      end

      def source_type_from(authorization)
        _, _, source_type = split_authorization(authorization)
        (source_type || 'credit_card').to_sym
      end

      def add_source(post, source)
        if source.respond_to?(:brand)
          add_credit_card(post, source)
        elsif source.respond_to?(:routing_number)
          add_check(post, source)
        elsif source.is_a?(String)
          add_cardknox_token(post, source)
        else
          raise ArgumentError, "Invalid payment source #{source.inspect}"
        end
      end

      # Subtotal + Tax + Tip = Amount.

      def add_amount(post, money, options = {})
        post[:Tip]    = amount(options[:tip])
        post[:Amount] = amount(money)
      end

      def expdate(credit_card)
        year  = format(credit_card.year, :two_digits)
        month = format(credit_card.month, :two_digits)
        "#{month}#{year}"
      end

      def add_customer_data(post, options)
        address = options[:billing_address] || {}
        post[:Street] = address[:address1]
        post[:Zip] = address[:zip]
        post[:PONum] = options[:po_number]
        post[:Fax] = options[:fax]
        post[:Email] = options[:email]
        post[:IP] = options[:ip]
      end

      def add_address(post, source, options)
        add_address_for_type(:billing, post, source, options[:billing_address]) if options[:billing_address]
        add_address_for_type(:shipping, post, source, options[:shipping_address]) if options[:shipping_address]
      end

      def add_address_for_type(type, post, source, address)
        prefix = address_key_prefix(type)
        if source.respond_to?(:first_name)
          post[address_key(prefix, 'FirstName')] = source.first_name
          post[address_key(prefix, 'LastName')]  = source.last_name
        else
          post[address_key(prefix, 'FirstName')] = address[:first_name]
          post[address_key(prefix, 'LastName')]  = address[:last_name]
        end
        post[address_key(prefix, 'MiddleName')] = address[:middle_name]

        post[address_key(prefix, 'Company')]  = address[:company]
        post[address_key(prefix, 'Street')]   = address[:address1]
        post[address_key(prefix, 'Street2')]  = address[:address2]
        post[address_key(prefix, 'City')]     = address[:city]
        post[address_key(prefix, 'State')]    = address[:state]
        post[address_key(prefix, 'Zip')]      = address[:zip]
        post[address_key(prefix, 'Country')]  = address[:country]
        post[address_key(prefix, 'Phone')]    = address[:phone]
        post[address_key(prefix, 'Mobile')]   = address[:mobile]
      end

      def address_key_prefix(type)
        case type
        when :shipping then 'Ship'
        when :billing then 'Bill'
        else
          raise ArgumentError, "Unknown address key prefix: #{type}"
        end
      end

      def address_key(prefix, key)
        "#{prefix}#{key}".to_sym
      end

      def add_invoice(post, options)
        post[:Invoice] = options[:invoice]
        post[:OrderID] = options[:order_id]
        post[:Comments] = options[:comments]
        post[:Description] = options[:description]
        post[:Tax] = amount(options[:tax])
      end

      def add_custom_fields(post, options)
        options.keys.grep(/^custom(?:[01]\d|20)$/) do |key|
          post[key.to_s.capitalize] = options[key]
        end
      end

      def add_credit_card(post, credit_card)
        if credit_card.track_data.present?
          post[:Magstripe] = credit_card.track_data
          post[:Cardpresent] = true
        else
          post[:CardNum] = credit_card.number
          post[:CVV] = credit_card.verification_value
          post[:Exp] = expdate(credit_card)
          post[:Name] = credit_card.name
          post[:CardPresent] = true if credit_card.manual_entry
        end
      end

      def add_check(post, check)
        post[:Routing] = check.routing_number
        post[:Account] = check.account_number
        post[:Name] = check.name
        post[:CheckNum] = check.number
      end

      def add_cardknox_token(post, authorization)
        _, token, = split_authorization(authorization)

        post[:Token] = token
      end

      def parse(body)
        fields = {}
        body.split('&').each do |line|
          key, value = *line.scan(/^(\w+)=(.*)$/).flatten
          fields[key] = CGI.unescape(value.to_s)
        end

        {
          :result => fields['xResult'],
          :status => fields['xStatus'],
          :error => fields['xError'],
          :auth_code => fields['xAuthCode'],
          :ref_num => fields['xRefNum'],
          :current_ref_num => fields['xRefNumCurrent'],
          :token => fields['xToken'],
          :batch => fields['xBatch'],
          :avs_result => fields['xAvsResult'],
          :avs_result_code => fields['xAvsResultCode'],
          :cvv_result => fields['xCvvResult'],
          :cvv_result_code => fields['xCvvResultCode'],
          :remaining_balance => fields['xRemainingBalance'],
          :amount => fields['xAuthAmount'],
          :masked_card_num => fields['xMaskedCardNumber'],
          :masked_account_number => fields['MaskedAccountNumber']
        }.delete_if { |_k, v| v.nil? }
      end

      def commit(action, source_type, parameters)
        response = parse(ssl_post(live_url, post_data(COMMANDS[source_type][action], parameters)))

        Response.new(
          (response[:status] == 'Approved'),
          message_from(response),
          response,
          :authorization => authorization_from(response, source_type),
          :avs_result => { :code => response[:avs_result_code] },
          :cvv_result => response[:cvv_result_code]
        )
      end

      def message_from(response)
        if response[:status] == 'Approved'
          'Success'
        elsif response[:error].blank?
          'Unspecified error'
        else
          response[:error]
        end
      end

      def authorization_from(response, source_type)
        "#{response[:ref_num]};#{response[:token]};#{source_type}"
      end

      def post_data(command, parameters = {})
        initial_parameters = {
          :Key => @options[:api_key],
          :Version => '4.5.9',
          :SoftwareName => 'Open Campground',
          :SoftwareVersion => '1.11',
          :Command => command
        }

        seed = SecureRandom.hex(32).upcase
        hash = Digest::SHA1.hexdigest("#{initial_parameters[:command]}:#{@options[:pin]}:#{parameters[:amount]}:#{parameters[:invoice]}:#{seed}")
        initial_parameters[:Hash] = "s/#{seed}/#{hash}/n" unless @options[:pin].blank?
        parameters = initial_parameters.merge(parameters)

        parameters.reject { |_k, v| v.blank? }.collect { |key, value| "x#{key}=#{CGI.escape(value.to_s)}" }.join('&')
      end
    end
  end
end
