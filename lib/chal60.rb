class Chal60
  # B*v^2 = u^3 + A*u^2 + u
  class MontgomeryCurve
    def initialize(p, a, b)
      @p = p
      @a = a
      @b = b
      @p_bitlen = @p.to_s(2).size
    end

    def cswap(x, y, c)
      if c == 0
        [x, y]
      else
        [y, x]
      end
    end

    def ladder(u, k)
      u2, w2 = [1, 0]
      u3, w3 = [u, 1]

      (0...@p_bitlen).reverse_each do |i|
        b = 1 & (k >> i)
        u2, u3 = cswap(u2, u3, b)
        w2, w3 = cswap(w2, w3, b)
        u3, w3 = ((u2*u3 - w2*w3)**2) % @p, (u * (u2*w3 - w2*u3)**2) % @p
        u2, w2 = ((u2**2 - w2**2)**2) % @p, (4*u2*w2 * (u2**2 + @a*u2*w2 + w2**2)) % @p
        u2, u3 = cswap(u2, u3, b)
        w2, w3 = cswap(w2, w3, b)
      end
      (u2 * w2.powmod(@p-2, @p)) % @p
    end
  end
end
