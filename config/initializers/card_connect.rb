# need to get the config info from card_connect table
begin
  int = Integration.first
  CardConnect.configure do |config|
    config.merchant_id = int.cc_merchant_id
    config.api_username = int.cc_api_username
    config.api_password = int.cc_api_password
    config.endpoint = int.cc_endpoint
  end

rescue
end
