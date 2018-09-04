class WeierstrassCurve
  attr_reader :p, :a, :b
  def initialize(p, a, b)
    @p = p
    @a = a % p
    @b = b % p

    if (4 * (@a**3) + 27 * (@b**2) % @p) == 0
      raise "Incorrect curve"
    end
  end

  def valid?(point)
    return true if point == :infinity
    x, y = point
    (-(y**2) + (x**3) + a*x + b) % p == 0
  end

  def negate(point)
    return point if point == :infinity
    x, y = point
    [x, -y % p]
  end

  def add(p1, p2)
    return p2 if p1 == :infinity
    return p1 if p2 == :infinity
    return :infinity if p1 == negate(p2)

    x1, y1 = p1
    x2, y2 = p2

    if p1 == p2
      m = ((3*x1*x1 + a) * (2*y1).invmod(@p)) % @p
    else
      m = ((y2-y1) * (x2-x1).invmod(@p)) % @p
    end

    xr = (m*m - x1 - x2) % @p
    yr = (m * (x1 - xr) - y1) % @p
    [xr, yr]
  end

  def multiply(point, n)
    result = :infinity
    if n < 0
      n = -n
      point = negate(point)
    end

    while n > 0
      if n.odd?
        result = add(result, point)
      end
      n >>= 1
      point = add(point, point)
    end

    result
  end

  # infinity is technically a point too, but don't bother
  def random_point
    while true
      x = rand(0...@p)
      yy = (x**3 + @a*x + @b) % @p
      y = yy.sqrtmod(@p)
      if y
        if rand(2) == 0
          return [x, y]
        else
          return [x, @p-y]
        end
      end
    end
  end

  def random_point_of_order(group_order, requested_point_order)
    raise "Invalid request" if group_order % requested_point_order != 0
    m = group_order / requested_point_order
    while true
      point = multiply(random_point, m)
      return point unless point == :infinity
    end
  end

  # Various algorithms for counting points:
  # O(p^2) - brute force
  def points_n2
    result = [:infinity]
    (0...@p).each do |x|
      (0...@p).each do |y|
        point = [x,y]
        result << point if valid?(point)
      end
    end
    result
  end

  # O(p^1) - very slow
  def points
    result = [:infinity]
    (0...@p).each do |x|
      yy = ((x**3) + a*x + b) % @p
      y = yy.sqrtmod(@p)
      next unless y
      point = [x, y]
      result << point if valid?(point)
      # p-y === y
      # p === 2y
      # So if p is even or y is zero
      if y != 0
        point2 = [x, @p - y]
        result << point2 if valid?(point2)
      end
    end
    result
  end

  def ==(other)
    other.is_a?(WeierstrassCurve) and self.p == other.p and self.a == other.a and self.b == other.b
  end
end
