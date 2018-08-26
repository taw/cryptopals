class Chal60
  # B*v^2 = u^3 + A*u^2 + u
  class MontgomeryCurve
    def initialize(p, a, b)
      @p = p
      @a = a
      @b = b
      @binv = @b.invmod(@p)
      @third = 3.invmod(@p)
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

    def calculate_v(u)
      bvv = (u*u*u + @a*u*u + u) % @p
      vv = (bvv * @binv) % @p
      v = vv.sqrtmod(@p)
      return unless v
      [v, @p-v].sort
    end

    def valid?(u, v)
      bvv = (u*u*u + @a*u*u + u) % @p
      vv = (bvv * @binv) % @p
      0 == (v*v - vv) % @p
    end

    def associated_weierstrass_curve
      a = ((3-@a*@a) * (3*@b*@b).invmod(@p)) % @p
      b = ((2*@a*@a*@a - 9*@a) * (27*@b*@b*@b).invmod(@p)) % @p
      ECC.new(@p, a, b)
    end

    # This seems backwards from what I've read
    # Also doesn't handle point at infinity
    def to_weierstrass(u, v)
      x = (@b*u + @a*@third) % @p
      y = (v * @b) % @p
      [x, y]
    end

    def from_weierstrass(x, y)
      u = ((x - @a * @third) * @binv) % @p
      v = (y * @binv) % @p
      [u, v]
    end
  end
end
