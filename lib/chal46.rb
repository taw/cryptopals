class Chal46
  def derive_d(p, q, e)
    e.invmod((p-1)*(q-1))
  end

  class Oracle
    def initialize(n, d)
      @n = n
      @d = d
    end

    def even?(ct)
      ct.powmod(@d, @n).even?
    end
  end

  def hack(n, e, ct, oracle)
    k = n.to_s(2).size
    c2 = 2.powmod(e, n)
    u = BigDecimal(n, k)
    l = BigDecimal(0, k)
    c = ct
    while l.ceil != u.floor
      c = (c2*c) % n
      m = (u+l) / 2
      if oracle.even?(c)
        u = m
      else
        l = m
      end
    end
    l.ceil
  end
end
