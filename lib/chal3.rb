class XorCracker
  def initialize(input)
    @input = input
  end

  def xor(str, key)
    str.chars.map{|c| (c.ord ^ key).chr}.join
  end

  # Not any serious model
  def score(str)
    str.chars.map do |c|
      if c.ord > 127
        10.0
      elsif c == " "
        0.0
      elsif c =~ /[a-z]/
        1.0
      elsif c =~ /[A-Z0-9]/
        2.0
      else
        4.0
      end
    end.sum
  end

  def call
    (0..255).map{|key|
      decoded = xor(@input, key)
      [score(decoded), key, decoded]
    }.sort[0][2]
  end
end
