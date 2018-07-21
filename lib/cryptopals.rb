Dir["#{__dir__}/chal*.rb"].each do |path|
  require path
end

class String
  def unpack_hex
    [self].pack("H*")
    # scan(/../).map{|x| x.to_i(16).chr}.join
  end
end
