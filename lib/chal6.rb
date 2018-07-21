class Chal6
  def hamming_distance(str1, str2)
    raise unless str1.size == str2.size
    str1.unpack("C*").zip(str2.unpack("C*")).map{|u,v| (u^v).count_bits}.sum
  end
end
