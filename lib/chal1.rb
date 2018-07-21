require "base64"

module Chal1
  def self.call(input)
    text = input.scan(/../).map{|x| x.to_i(16).chr}.join
    Base64.strict_encode64(text)
  end
end
