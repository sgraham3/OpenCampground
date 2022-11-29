class Setup::PaypalsController < ApplicationController

  # GET /setup_paypals/new
  def new
    debug 'setup_paypals.new'
    @paypal = Paypal.new :create_keyfile => false,
			 :check_keyfile => File.exists?(Paypal::Keyfile) 
    unless File.exists? Paypal::Randfile
      rand = Integer("0x" + request.session_options[:id] )
      fd = File.new Paypal::Randfile, "w"
      fd.write "#{rand.to_s}\n"
      fd.close
    end
  end

  # POST /setup_paypals
  def create
    debug 'setup_paypals.create'
    if params[:create_keyfile]
      new_params = (params[:paypal].merge({:servername => params[:servername],:create_keyfile => params[:create_keyfile]}))
    else
      new_params = (params[:paypal].merge({:servername => params[:servername]}))
    end
    debug new_params.inspect
    @paypal = Paypal.new(new_params)
    # generate and save keyfile if we want a new one
    debug "create_keyfile is #{@paypal.create_keyfile}"
    if @paypal.create_keyfile == 'true'
      debug 'generating key'
      status = @paypal.generate_p_key
      debug "key status is #{status}"
    end
    # generate certfile
    debug 'generating cert'
    status = @paypal.generate_p_cert
    debug "cert status is #{status}"
    if status
      debug 'cert generated'
      flash[:notice] = "Certificate generated"
			redirect_to setup_paypals_url
    else
      error "Certificate generation failed"
      flash[:error] = "Certificate generation failed"
      redirect_to new_setup_paypals_url
    end
  end

	def show
		@page_title = 'Download public certificate'
	end

	def certificate
      @filename = "config/paypal/my-pubcert.pem"
      send_file(@filename,  :filename => "my-pubcert.pem")
      debug 'file sent'
      flash[:notice] = "Certificate generated and downloaded"
	end

end
