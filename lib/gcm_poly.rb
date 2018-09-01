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
    sum = GCMPoly.new []
    @a.each do |a|
      sum += other * a
      other <<= 1
    end
    sum
  end

  def divmod(other)
    raise ZeroDivisionError, "Can't divide by zero" if other.zero?
    q = GCMPoly.new([])
    r = self
    b = other

    while r.degree >= b.degree
      d = r.degree - b.degree
      u = r.a.last / b.a.last
      q += (GCMPoly.new([u]) << d)
      r += (b*u << d)
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
    return self + GCMPoly.new([other]) if other.is_a?(GCMField)
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
  # Is q characteristic ???
  def distinct_degree_factorization
    result = []
    i = 1
    fstar = self
    x = GCMPoly[GCMField.zero, GCMField.one]
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

  def **(k)
    raise unless k.is_a?(Integer)
    if k < 0
      return inverse ** (-k)
    end
    result = GCMPoly[GCMField.one]
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

  class << self
    def [](*a)
      new(a)
    end
  end
end
