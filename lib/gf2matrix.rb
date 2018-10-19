class GF2Matrix
  attr_reader :coeff

  def size
    @coeff.size
  end

  def initialize(coeff)
    @coeff = coeff
  end

  def +(other)
    raise unless other.is_a?(GF2Matrix)
    raise unless size == other.size
    GF2Matrix.new @coeff.zip(other.coeff).map{|u,v| u^v}
  end

  def **(k)
    raise unless k.is_a?(Integer)
    return GF2Matrix.identity(size) if k == 0
    return inverse ** -k if k < 0

    result = GF2Matrix.identity(size)
    m = self
    while k > 0
      if k.odd?
        result = result * m
      end
      m = m*m
      k /= 2
    end
    result
  end

  def inverse
    raise "TODO"
  end

  def vec_mul(v)
    result = 0
    @coeff.each_with_index do |c, i|
      result ^= c if v[i] == 1
    end
    result
  end

  def matrix_mul(other)
    raise unless other.is_a?(GF2Matrix) and size == other.size
    GF2Matrix.build(size) do |i|
      self*(other*i)
    end
  end

  def *(other)
    if other.is_a?(GF2Matrix)
      matrix_mul(other)
    elsif other.is_a?(Integer)
      vec_mul(other)
    else
      raise "Unknown type"
    end
  end

  def ==(other)
    other.is_a?(GF2Matrix) and @coeff == other.coeff
  end

  class << self
    def build(size)
      new (0...size).map{|i| yield(1 << i) }
    end

    def identity(size)
      build(size){|x| x }
    end

    def zero(size)
      build(size){|x| 0 }
    end

    def random(size)
      max = 2**size - 1
      build(size){ rand(0..max) }
    end
  end
end
