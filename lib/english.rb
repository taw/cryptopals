# Not any serious model
module English
  def self.score(str)
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
end
