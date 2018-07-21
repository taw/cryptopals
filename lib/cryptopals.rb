require "base64"
require "set"
require "openssl"

require_relative "english"

Dir["#{__dir__}/chal*.rb"].each do |path|
  require path
end

class String
  def unpack_hex
    [self].pack("H*")
  end

  def pack_hex
    self.unpack("H*")[0]
  end
end

class Integer
  def count_bits
    raise if self < 0
    result = 0
    n = self
    while n > 0
      result += (n&1)
      n >>= 1
    end
    result
  end
end
