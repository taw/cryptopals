module Chal1
  def self.call(input)
    Base64.strict_encode64(input.from_hex)
  end
end
