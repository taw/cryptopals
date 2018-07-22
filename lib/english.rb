# Not any serious model
module English
  def self.score(str)
    str.chars.map do |c|
      # Weirdo characters almost never occur
      if c.ord > 126
        1000.0
      elsif c.ord < 32 and c.ord != 10 and c.ord != 13 and c.ord != 10
        1000.0
      elsif c == " "
        0.0
      elsif c =~ /[etaoin]/
        1.0
      elsif c =~ /[a-z]/
        2.0
      elsif c =~ /[A-Z]/
        4.0
      elsif c =~ /[01\.\,\n]/
        10.0
      elsif c =~ /[2-9\/!?';\-]/
        20.0
      else
        50.0
      end
    end.sum
  end
end
