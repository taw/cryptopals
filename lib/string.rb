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

  def xor(other)
    s1 = unpack("C*")
    s2 = other.unpack("C*")
    raise "Incompatible sizes" unless s1.size == s2.size
    s1.zip(s2).map{|u,v| u^v}.pack("C*")
  end
end
