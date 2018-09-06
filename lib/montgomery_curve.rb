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

  def constant_time_ladder(u, k)
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

  def ladder(u, k)
    u2, w2 = [1, 0]
    u3, w3 = [u, 1]

    bitlen = [@p_bitlen-1, k.to_s(2).size].min
    (0..bitlen).reverse_each do |i|
      b = 1 & (k >> i)
      if b == 0
        u3, w3 = ((u2*u3 - w2*w3)**2) % @p, (u * (u2*w3 - w2*u3)**2) % @p
        u2, w2 = ((u2**2 - w2**2)**2) % @p, (4*u2*w2 * (u2**2 + @a*u2*w2 + w2**2)) % @p
      else
        u2, u3 = u3, u2
        w2, w3 = w3, w2
        u3, w3 = ((u2*u3 - w2*w3)**2) % @p, (u * (u2*w3 - w2*u3)**2) % @p
        u2, w2 = ((u2**2 - w2**2)**2) % @p, (4*u2*w2 * (u2**2 + @a*u2*w2 + w2**2)) % @p
        u2, u3 = u3, u2
        w2, w3 = w3, w2
      end
    end

    if w2 == 0
      inv_w2 = 0
    else
      inv_w2 = w2.invmod(@p)
    end
    (u2 * inv_w2) % @p
  end

  def multiply(u, k)
    ladder(u, k)
  end

  def calculate_v(u)
    bvv = (u*u*u + @a*u*u + u) % @p
    vv = (bvv * @binv) % @p
    v = vv.sqrtmod(@p)
    return unless v
    [v, @p-v].sort
  end

  def valid?(u, v=nil)
    bvv = (u*u*u + @a*u*u + u) % @p
    vv = (bvv * @binv) % @p
    if v
      0 == (v*v - vv) % @p
    else
      !!vv.sqrtmod(@p)
    end
  end

  def associated_weierstrass_curve
    a = ((3-@a*@a) * (3*@b*@b).invmod(@p)) % @p
    b = ((2*@a*@a*@a - 9*@a) * (27*@b*@b*@b).invmod(@p)) % @p
    WeierstrassCurve.new(@p, a, b)
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

  def random_point
    while true
      u = rand(1...@p)
      return u if calculate_v(u)
    end
  end

  def random_twist_point
    while true
      u = rand(1...@p)
      return u unless calculate_v(u)
    end
  end

  # Will loop forever if twist_order is invalid
  # If q is not prime, it can give you any non-1 order which divides q
  def random_twist_point_of_order(twist_order, q)
    raise unless twist_order % q == 0
    1000.times do
      u = ladder(random_twist_point, twist_order/q)
      return u if u != 0 and ladder(u, q) == 0
    end
    raise "Failed to find twist factor of order #{q}, something is probably wrong"
  end
end
