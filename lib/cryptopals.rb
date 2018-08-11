require "base64"
require "bigdecimal"
require "net/http"
require "openssl"
require "pry"
require "rack"
require "set"
require "z3"
require_relative "aes"
require_relative "dh"
require_relative "dsa"
require_relative "english"
require_relative "integer"
require_relative "rsa"
require_relative "string"

Dir["#{__dir__}/chal*.rb"].sort_by{|x| x[/\d+/].to_i }.each do |path|
  require path
end
