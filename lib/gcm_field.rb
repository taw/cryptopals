# GF(2^128) mod x**128 + x**7 + x** + x + 1, backwards
# The weird-ass group used by GCM and nothing else
class GCMField
  attr_reader :value
  def initialize(value)
    @value = value
  end

  def +(other)
    GCMField.new(value ^ other.value)
  end

  def -(other)
    GCMField.new(value ^ other.value)
  end

  def ==(other)
    other.is_a?(GCMField) and value == other.value
  end

  def *(other)
    a, b = @value, other.value
    result = 0
    mask = 2**128 + 2**127 + 2**126 + 2**121 + 1
    max = 2**128
    while a > 0 and b > 0
      if b[127] == 1
        result ^= a
      end
      b = (b << 1) & (max - 1)

      if a.odd?
        a ^= mask
      end
      a >>= 1
    end
    GCMField.new(result)
  end

  def **(k)
    raise unless k.is_a?(Integer)
    if k < 0
      return inverse ** (-k)
    end
    result = GCMField.one
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

  def to_i
    @value
  end

  def hash
    @value.hash
  end

  def inverse
    raise ZeroDivisionError, "Can't invert 0" if @value == 0
    self ** ((1 << 128) - 2)
  end

  def sqrt
    self ** (1 << 127)
  end

  def /(other)
    self * other.inverse
  end

  # This looks slow as hell
  private def degree(value)
    index = value.to_s(2).reverse.index("1")
    if index
      127 - index
    else
      -1
    end
  end

  def to_s
    ("%0128b" % @value).reverse
  end

  def inspect
    "GCMField<#{to_s}>"
  end

  def zero?
    @value == 0
  end

  def one?
    @value == (1 << 127)
  end

  class << self
    def zero
      GCMField.new(0)
    end

    def one
      GCMField.new(1 << 127)
    end

    def from_i(value)
      GCMField.new(value)
    end

    def random
      GCMField.new(rand(1 << 128))
    end
  end
end
