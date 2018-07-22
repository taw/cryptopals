require "base64"
require "set"
require "openssl"

require_relative "integer"
require_relative "string"
require_relative "aes"
require_relative "english"

Dir["#{__dir__}/chal*.rb"].each do |path|
  require path
end
