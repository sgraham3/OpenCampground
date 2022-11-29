# workaround for security bug CVE-2013-0156
# The parameter parsing code of Ruby on Rails allows applications to automatically cast 
# values from strings to certain data types.  Unfortunately the type casting code supported 
# certain conversions which were not suitable for performing on user-provided data including 
# creating Symbols and parsing YAML.  These unsuitable conversions can be used by an 
# attacker to compromise a Rails application. 
#
# this workaround will disable parsing of XML parameters as we do not use XML parameters
# this will eliminate the problem.
ActionController::Base.param_parsers.delete(Mime::XML) 
