require "base64"
require "set"
require "openssl"

require_relative "english"

Dir["#{__dir__}/chal*.rb"].each do |path|
  require path
end

class String
  def from_hex
    [self].pack("H*")
  end

  def to_hex
    self.unpack("H*")[0]
  end

  def to_hex_pretty
    self.unpack("C*").map{|x| "%02x" % x}.join(" ")
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

  def powmod(exponent, modulus)
    return 0 if modulus == 1
    result = 1
    base = self % modulus
    while exponent > 0
      result = result*base%modulus if exponent%2 == 1
      exponent = exponent >> 1
      base = base*base%modulus
    end
    result
  end
  end

module AES
  def self.encrypt_block(block, key)
    raise unless block.size == 16 and key.size == 16
    decipher = OpenSSL::Cipher.new("AES-128-ECB")
    decipher.encrypt
    decipher.padding = 0
    decipher.key = key
    decipher.update(block) + decipher.final
  end

  def self.decrypt_block(block, key)
    raise unless block.size == 16 and key.size == 16
    decipher = OpenSSL::Cipher.new("AES-128-ECB")
    decipher.decrypt
    decipher.padding = 0
    decipher.key = key
    decipher.update(block) + decipher.final
  end
end
