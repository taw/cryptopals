class Chal21
  def state
    @x.dup
  end

  def initialize
    @x = [0] * n
    @index = n+1 # Special fake value
  end

  def seed(v)
    @x[0] = v
    (1..n-1).each do |i|
      @x[i] = (f * (@x[i-1] ^ (@x[i-1] >> (w-2))) + i) & 0xFFFF_FFFF
    end
    @index = n
  end

  def extract_number
    if index >= n
      if index > n
        raise "RNG was never seeded"
      end
      twist
    end

    y = @x[index]
    y ^= ((y >> u) & d)
    y ^= ((y << s) & b)
    y ^= ((y << t) & c)
    y ^= (y >> l)

    @index += 1

    y & 0xFFFF_FFFF
  end

  def twist
    (0...n).each do |i|
      xi  = @x[i] & upper_mask
      xi1 = @x[(i+1) % n] & lower_mask
      x = xi + xi1
      xa = x >> 1
      if x % 2 != 0
        xa ^= a
      end
      @x[i] = @x[(i + m) % n] ^ xa
    end
  end

  ### Derived constants
  def lower_mask
    (1 << r) - 1
  end

  def upper_mask
    (~lower_mask) & 0xFFFF_FFFF
  end

  ### Various constants
  def w
    32
  end

  def n
    624
  end

  def m
    397
  end

  def r
    31
  end

  def a
    0x9908B0DF
  end

  def u
    11
  end

  def d
    0xFFFFFFFF
  end

  def s
    7
  end

  def b
    0x9D2C5680
  end

  def t
    15
  end

  def c
    0xEFC60000
  end

  def l
    18
  end

  def f
    1812433253
  end
end
