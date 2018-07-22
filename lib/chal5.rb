class Chal5
  def call(str, key)
    str = str.unpack("C*")
    key = key.unpack("C*")
    (0...str.size).map do |i|
      (str[i] ^ key[i % key.size])
    end.pack("C*")
  end
end
