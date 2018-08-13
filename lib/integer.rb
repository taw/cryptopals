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

  # https://rosettacode.org/wiki/Tonelli-Shanks_algorithm
  def legendre(p)
    self.powmod((p - 1) / 2, p)
  end

  def tonelli_sqrtmod(p)
    return nil unless legendre(p) == 1

    n = self
    q = p - 1
    s = 0
    while q % 2 == 0
      q /= 2
      s += 1
    end

    if s == 1
      return n.powmod(n(p + 1) / 4, p)
    end

    for z in (2...p)
      if p - 1 == z.legendre(p)
        break
      end
    end

    c = z.powmod(q, p)
    r = n.powmod((q + 1) / 2, p)
    t = n.powmod(q, p)
    m = s
    t2 = 0
    while (t - 1) % p != 0
      t2 = (t * t) % p
      for i in (1...m)
        if (t2 - 1) % p == 0
          break
        end
        t2 = (t2 * t2) % p
      end
      b = c.powmod(1 << (m - i - 1), p)
      r = (r * b) % p
      c = (b * b) % p
      t = (t * c) % p
      m = i
    end
    r
  end

  def sqrtmod(p)
    if p % 4 == 3
      m = (p+1) / 4
      self.powmod(m, p)
    else
      self.tonelli_sqrtmod(p)
    end
  end

  def root(n)
    raise "Can't integer root negative number" if n < 0
    (0..self).bsearch{|i| self - i**n }
  end

  def self.chinese_remainder(remainders, mods)
    max = mods.reduce(:*)
    series = remainders.zip(mods).map{ |r,m| (r * max * (max/m).invmod(m) / m) }
    series.reduce(:+) % max
  end
end
