module Chal2
  def self.call(input, key)
    input.xor(key)
  end
end
