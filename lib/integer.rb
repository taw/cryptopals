class Integer
  def count_bits
    raise if self < 0
    result = 0
    n = self
    while n > 0
      result += (n&1)
      n >>= 1
    end
    result
  end

  def powmod(exponent, modulus)
    return 0 if modulus == 1
    result = 1
    base = self % modulus
    while exponent > 0
      result = result*base%modulus if exponent%2 == 1
      exponent = exponent >> 1
      base = base*base%modulus
    end
    result
  end

  def extended_gcd(b)
    a = self
    last_remainder, remainder = a.abs, b.abs
    x, last_x, y, last_y = 0, 1, 1, 0
    while remainder != 0
      last_remainder, (quotient, remainder) = remainder, last_remainder.divmod(remainder)
      x, last_x = last_x - quotient*x, x
      y, last_y = last_y - quotient*y, y
    end

    return last_remainder, last_x * (a < 0 ? -1 : 1)
  end

  def invmod(et)
    g, x = extended_gcd(et)
    raise "The maths are broken!" unless g == 1
    x % et
  end

  def root(n)
    raise "Can't integer root negative number" if n < 0
    (0..self).bsearch{|i| self - i**n }
  end
end
