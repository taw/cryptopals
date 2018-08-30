# Polynomial over GCMField
class GCMPoly
  attr_reader :a
  def initialize(a)
    @a = a.dup
    @a.pop while @a.last and @a.last.zero?
  end

  def degree
    @a.size - 1
  end

  def +(other)
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
    return self if @a.empty?
    factor = @a.last.inverse
    GCMPoly.new @a.map{|c| c * factor }
  end

  # Doing it stupid way here
  def eval(h)
    return GCMField.zero if @a.empty?
    @a.map.with_index{|b,i|
      h ** (i+1) * b
    }.inject{|a,b| a+b}
  end
end
