require_relative "english"

Dir["#{__dir__}/chal*.rb"].each do |path|
  require path
end

class String
  def unpack_hex
    [self].pack("H*")
  end

  def pack_hex
    self.unpack("H*")
  end
end
