# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
begin
  opt = Option.first
  ActionController::Base.cookie_verifier_secret = OC_VERSION + opt.cookie_token || OC_VERSION + 'ac0921a9f550090ba8bbc505a10fdd18f212235fdb7e67a91ca23fb2163b3c8bff7115dccb48be41f163d0fbeaa2c95b0823772d06cd59f89f1a0d918a2c97b1'
rescue
  ActionController::Base.cookie_verifier_secret = OC_VERSION + 'ac0921a9f550090ba8bbc505a10fdd18f212235fdb7e67a91ca23fb2163b3c8bff7115dccb48be41f163d0fbeaa2c95b0823772d06cd59f89f1a0d918a2c97b1'
end
