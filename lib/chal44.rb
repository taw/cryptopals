class Chal44
  def hack(public_key, samples)
    q = public_key.q
    multiples = samples.uniq.group_by(&:r).values.select{|v| v.size > 1}
    raise "No r reuse so attack can't work" if multiples.empty?
    # We just need one pair
    a, b = multiples[0]
    k = ((a.h - b.h) * (a.s - b.s).invmod(q)) % q
    x = ((a.s * k - a.h) * a.r.invmod(q)) % q
    DSA::PrivateKey.new(public_key.group, x)
  end
end
