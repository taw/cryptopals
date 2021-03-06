# Polynomial over GCMField
# Least significant coefficient first
class GCMPoly
  attr_reader :a
  def initialize(a)
    @a = a.dup
    @a.pop while @a.last and @a.last.zero?
  end

  def degree
    @a.size - 1
  end

  def <<(k)
    raise unless k.is_a?(Integer) and k >= 0
    GCMPoly.new [GCMField.zero] * k + @a
  end

  def >>(k)
    raise unless k.is_a?(Integer) and k >= 0
    GCMPoly.new @a.drop(k)
  end

  def *(other)
    if other.is_a?(GCMField)
      return GCMPoly.new a.map{|b| b*other}
    end
    sum = GCMPoly.zero
    @a.each do |a|
      sum += other * a
      other <<= 1
    end
    sum
  end

  def divmod(other)
    raise ZeroDivisionError, "Can't divide by zero" if other.zero?
    q = GCMPoly.zero
    r = self
    b = other

    while r.degree >= b.degree
      d = r.degree - b.degree
      u = r.highest / b.highest
      q += GCMPoly[u] << d
      r += b*u << d
    end

    return q, r
  end

  def /(other)
    divmod(other)[0]
  end

  def %(other)
    divmod(other)[1]
  end

  def gcd(other)
    return other if zero?
    return self if other.zero?
    a = self.to_monic
    b = other.to_monic
    a, b = b, a if a.degree < b.degree
    q, r = a.divmod(b)
    if r.zero?
      b
    else
      b.gcd(r)
    end
  end

  def +(other)
    return self + GCMPoly[other] if other.is_a?(GCMField)
    raise unless other.is_a?(GCMPoly)
    m1 = a
    m2 = other.a
    max_size = [m1.size, m2.size].max
    GCMPoly.new max_size.times.map{|i|
      m1.fetch(i, GCMField.zero) + m2.fetch(i, GCMField.zero)
    }
  end

  def -(other)
    self+other
  end

  def to_monic
    return self if zero? or monic?
    factor = @a.last.inverse
    GCMPoly.new @a.map{|c| c * factor }
  end

  def eval(h)
    return GCMField.zero if zero?
    sum = GCMField.zero
    hi = GCMField.one
    @a.each do |b|
      sum += hi * b
      hi *= h
    end
    sum
  end

  def ==(other)
    other.is_a?(GCMPoly) and @a == other.a
  end

  def monic?
    @a.last.one?
  end

  def zero?
    @a.empty?
  end

  def one?
    @a.size == 1 and @a[0].one?
  end

  def sqrt
    result = []
    @a.each_with_index do |a, i|
      if i.even?
        result << a.sqrt
      else
        raise "No sqrt" unless a.zero?
      end
    end
    GCMPoly.new result
  end

  # It's not supposed to be in monic conversion business
  def square_free_factorization
    f = self
    result = []
    unless f.monic?
      result << GCMPoly[@a.last]
      f = f.to_monic
    end

    df = f.formal_derivative

    if df.zero?
      # This branch is unclear
      c = f
    else
      c = f.gcd(df)
      w = f/c
      i = 1

      # Step 1: Identify all factors in w
      until w.one?
        y = w.gcd(c)
        fac = w/y
        unless fac.one?
          result.push *([fac] * i)
        end
        w = y
        c = c/y
        i += 1
      end
    end

    # c is now the product (with multiplicity) of the remaining factors of f
    # Step 2: Identify all remaining factors using recursion
    # Note that these are the factors of f that have multiplicity divisible by p
    unless c.one?
      cs = c.sqrt
      result.push *(cs.square_free_factorization * 2)
    end

    # I don't think it's possible to get multiple degree 0 polynomials this way
    result
  end

  # Underlying field has characteristic 2
  def formal_derivative
    GCMPoly.new (0...@a.size-1).map { |i| i.odd? ? GCMField.zero : @a[i+1] }
  end

  def powmod(exponent, modulus)
    return GCMPoly[GCMField.zero] if modulus.one?
    result = GCMPoly[GCMField.one]
    base = self % modulus
    while exponent > 0
      result = result*base%modulus if exponent.odd?
      exponent = exponent >> 1
      base = base*base%modulus
    end
    result
  end

  # Algorithm assumes it's a monic square-free polynomial
  def distinct_degree_factorization
    result = []
    i = 1
    fstar = self
    x = GCMPoly.x
    while fstar.degree >= 2*i
      xqix = x.powmod(2**(128*i), fstar) - x
      g = fstar.gcd(xqix)
      unless g.one?
        result << [g, i]
        fstar = fstar / g
      end
      i += 1
    end
    unless fstar.one?
      result << [fstar, fstar.degree]
    end
    if result.empty?
      result << [self, 1]
    end
    result
  end

  # It simply drops high degree factors as they won't lead to roots
  def distinct_degree_factorization_only_1
    result = []
    x = GCMPoly.x

    return nil if degree < 1
    return self if degree == 1

    xqix = x.powmod(2**128, self) - x
    g = self.gcd(xqix)

    return g unless g.one?
    return nil
  end

  def equal_degree_factorization(d)
    n = degree
    raise unless n % d == 0
    r = n / d
    f = self
    s = [f]
    q = 2**128
    one = GCMPoly.one

    while s.size < r
      h = GCMPoly.random(n)
      g = h.gcd(f)

      if g.one?
        x = (q**d - 1) / 3
        g = h.powmod(x, f) - one
      end

      s = s.flat_map do |u|
        if u.degree == d
          [u]
        else
          z = g.gcd(u)
          if z.one? or z == u
            [u]
          else
            [z, u/z]
          end
        end
      end
    end

    s
  end

  # Connect all algorithms
  def factorization
    return [self] if degree <= 1
    f = self
    result = []

    while f.lowest.zero?
      result << GCMField.x
      f >>= 1
    end

    unless f.monic?
      result << GCMPoly[f.highest]
      f = f.to_monic
    end

    sff_done, sff_todo = f.square_free_factorization.partition{|u| u.degree <= 1 }
    result += sff_done

    ddf_todo = sff_todo.flat_map{|f| f.distinct_degree_factorization}

    result + ddf_todo.flat_map{|f,d| f.equal_degree_factorization(d) }
  end

  # We don't need full factorization for this
  # so we can be a bit more performant here
  def roots_by_factorization
    factorization
      .select{|f| f.degree == 1}
      .map(&:lowest)
      .uniq
  end

  # This skips a lot of slow factorization parts which are not necessary
  # if all we want is roots
  def roots
    return [] if zero?
    f = to_monic
    result = []

    while f.lowest.zero?
      result << GCMField.x
      f >>= 1
    end

    sff_done, sff_todo = f.square_free_factorization.partition{|u| u.degree <= 1 }
    result += sff_done.map(&:lowest)

    ddf_todo = sff_todo.map{|f| f.distinct_degree_factorization_only_1}.compact

    result += ddf_todo.flat_map{|f| f.equal_degree_factorization(1) }.map(&:lowest)

    result.uniq
  end

  def **(k)
    raise unless k.is_a?(Integer)
    if k < 0
      return inverse ** (-k)
    end
    result = GCMPoly.one
    n = self
    while k > 0
      if k.odd?
        result *= n
      end
      k >>= 1
      n *= n
    end
    result
  end

  def inspect
    "GCMPoly<#{@a.map{|u| "%032x" % u.value}.join(", ")}>"
  end

  def lowest
    @a.first
  end

  def highest
    @a.last
  end

  class << self
    def [](*a)
      new(a)
    end

    def random(degree)
      GCMPoly.new (0..degree).map{ GCMField.random }
    end

    def zero
      GCMPoly[]
    end

    def one
      GCMPoly[GCMField.one]
    end

    def x
      GCMPoly[GCMField.zero, GCMField.one]
    end
  end
end
