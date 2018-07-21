class Chal8
  def likely_ecb?(sample)
    n = 0
    seen = Set[]
    while true
      slice = sample[n, 16]
      break if slice.size != 16
      return true if seen.include?(slice)
      seen << slice
      n += 16
    end
    false
  end

  def call(samples)
    samples.select{|sample| likely_ecb?(sample)}.map(&:pack_hex)
  end
end
