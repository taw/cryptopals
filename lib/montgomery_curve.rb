# B*v^2 = u^3 + A*u^2 + u
class MontgomeryCurve
  attr_reader :p, :a, :b
  def initialize(p, a, b)
    @p = p
    @a = a
    @b = b
    @binv = @b.invmod(@p)
    @third = 3.invmod(@p)
    @p_bitlen = @p.to_s(2).size
  end

  def to_twist
    if @b.sqrtmod(@p)
      twist_b = (2...@p).find{|x| not x.sqrtmod(@p) }
      raise "Math doesn't work" unless twist_b and not twist_b.sqrtmod(@p)
    else
      twist_b = 1
      raise "Math doesn't work" unless 1.sqrtmod(@p)
    end

    MontgomeryCurve.new(@p, @a, twist_b)
  end

  def add_by_weierstass(a, b)
    w = associated_weierstrass_curve
    w_ax = to_weierstrass_all(a)
    w_bx = to_weierstrass_all(b)
    w_cx = w_ax.flat_map{|w_a|
      w_bx.map{|w_b|
        w.add(w_a, w_b)
      }
    }.uniq
    w_cx.map{|w_c| from_weierstrass(w_c)[0] }
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

    (u2 * inverse(w2)) % @p
  end

  def inverse(u)
    return 0 if u == 0
    u.invmod(@p)
  end

  def multiply(u, k)
    ladder(u, k)
  end

  def diff_add(a, b, b_minus_a)
    u = b_minus_a
    u2, w2 = [b, 1]
    u3, w3 = [a, 1]

    if b_minus_a == 0
      u4 = ((u2**2 - w2**2)**2) % @p
      w4 = (4*u2*w2 * (u2**2 + @a*u2*w2 + w2**2)) % @p
    else
      u4 = ((u2*u3 - w2*w3)**2) % @p
      w4 = (u * (u2*w3 - w2*u3)**2) % @p
    end

    (u4 * inverse(w4)) % @p
  end

  def each_multiple(point, last_index)
    yield(0, 0)

    point_i = point
    diff = 0

    (1..last_index).each do |index|
      yield(point_i, index)
      point_i, diff = diff_add(point, point_i, diff), point_i
    end
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
  def to_weierstrass(uv)
    if uv.is_a?(Array)
      u, v = uv
      return :infinity if u == 0
    else
      return :infinity if uv == 0
      u = uv
      v, p_minus_v = calculate_v(u)
      raise "Point #{u} doesn't look valid for #{self}" unless v
    end
    x = (@b*u + @a*@third) % @p
    y = (v * @b) % @p
    [x, y]
  end

  def to_weierstrass_all(uv)
    if uv.is_a?(Array)
      [to_weierstrass(uv)]
    else
      return [:infinity] if uv == 0
      u = uv
      v, p_minus_v = calculate_v(u)
      [to_weierstrass([u, v]), to_weierstrass([u, p_minus_v])]
    end
  end

  def from_weierstrass(xy)
    return [0, 1] if xy == :infinity
    x, y = xy
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

  def ==(other)
    other.is_a?(self.class) and @p == other.p and @a == other.a and @b == other.b
  end
end
