class Chal6
  def hamming_distance(str1, str2)
    raise unless str1.size == str2.size
    str1.unpack("C*").zip(str2.unpack("C*")).map{|u,v| (u^v).count_bits}.sum
  end

  def repeated_edit_distance(str, n)
    i = 0
    total = 0
    while true
      break if 2*n + i > str.size
      str1 = str[i, n]
      str2 = str[i+n, n]
      total += hamming_distance(str1, str2)
      i += n
    end
    # Divide it here, to avoid
    total / i.to_f
  end

  def guess_keysize(str)
    (2..40).min_by{|k| repeated_edit_distance(str, k) }
  end
end
