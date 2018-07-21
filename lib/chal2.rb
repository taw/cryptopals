module Chal2
  def self.call(input, key)
    raise unless input.size == key.size
    (0...input.size).map{|i|
      (input[i].ord ^ key[i].ord).chr
    }.join
  end
end
