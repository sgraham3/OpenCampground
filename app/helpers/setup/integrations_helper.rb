module Setup::IntegrationsHelper
  def get_hsn
    return ' ' unless @integration.name.start_with?('CardConnect')
    arr = []
    c = CardTransaction.new
    resp = c.listTerminals
    if resp.class == Faraday::Response && resp.success?
      # logger.debug resp.inspect
      varray = (JSON.parse(resp.body))["terminals"]
      # the hash has one key 'terminals' 
      # the value is an array of terminal hsn's
      if varray.size > 0
        varray.each {|val| arr << val}
      else
	logger.debug 'array empty'
        arr[0] = 'None'
      end
    else
      arr[0] = 'None'
    end
    logger.debug arr.inspect
    arr
    # %w(None) # temporary for testing
  rescue
    %w(None)
  end

end
