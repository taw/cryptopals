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

  class << self
    def [](*a)
      new(a)
    end
  end
end
