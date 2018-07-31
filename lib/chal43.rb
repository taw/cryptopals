class Chal43
  def hack(signature)
    h = signature.h
    r = signature.r
    s = signature.s
    q = signature.q
    p = signature.p
    g = signature.g
    y = signature.y
    rinv = r.invmod(q)
    (0..2**16).each do |k|
      x = ((s*k - h) * rinv) % q
      if g.powmod(x, p) == y
        return DSA::PrivateKey.new(signature.group, x)
      end
    end
    raise "Attack failed"
  end
end
