require "base64"

module Chal1
  def self.call(input)
    Base64.strict_encode64(input.unpack_hex)
  end
end
