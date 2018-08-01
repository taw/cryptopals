require "base64"
require "set"
require "openssl"
require "bigdecimal"
require "pry"

require_relative "integer"
require_relative "string"
require_relative "aes"
require_relative "english"
require_relative "dh"
require_relative "dsa"

Dir["#{__dir__}/chal*.rb"].each do |path|
  require path
end
