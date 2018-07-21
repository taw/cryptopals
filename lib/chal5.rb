class Chal5
  def call(str, key)
    (0...str.size).map do |i|
      (str[i].ord ^ key[i % key.size].ord).chr
    end.join
  end
end
