class Chal40
  def decrypt(rsas, ciphertexts)
    ns = rsas.map(&:n)
    e, *other_es = rsas.map(&:e).uniq
    raise "Incompatible E" unless other_es.empty?
    raise unless rsas.size == ciphertexts.size
    warn "Probably not enough sampels" unless e <= rsas.size
    msg_e = chinese_remainder(ciphertexts, ns)
    msg_e.root(e)
  end

  def chinese_remainder(remainders, mods)
    max = mods.inject(:*)
    series = remainders.zip(mods).map{ |r,m| (r * max * (max/m).invmod(m) / m) }
    series.inject(:+) % max
  end
end
