class XorCracker
  def initialize(input)
    @input = input
  end

  def xor(str, key)
    str.chars.map{|c| (c.ord ^ key).chr}.join
  end

  def call
    (0..255).map{|key|
      decoded = xor(@input, key)
      [English.score(decoded), key, decoded]
    }.sort[0][2]
  end
end
