class Integer
  # ruby builtin prime? is ridiculously slow
  def fast_prime?
    OpenSSL::BN.new(self).prime?
  end

  def ceil_div(divisor)
    raise unless divisor.is_a?(Integer) and divisor > 0
    (self + divisor - 1) / divisor
  end

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

  def set_bit(i)
    self | (1 << i)
  end

  def clear_bit(i)
    self & ~(1 << i)
  end

  def copy_bit(source, i)
    if source[i] == 1
      set_bit(i)
    else
      clear_bit(i)
    end
  end

  def to_s_binary
    i = self
    out = []
    while i > 0
      c = i & 0xff
      i >>= 8
      out << c
    end
    out.pack("C*").reverse
  end

  def powmod(exponent, modulus)
    return 0 if modulus == 1
    if exponent < 0
      # There are surely faster ways
      return powmod(modulus-2, modulus).powmod(-exponent, modulus)
    end
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

  def divide_modulo(divisor, mod)
    (self * divisor.invmod(mod)) % mod
  end

  def root(n)
    raise "Can't integer root negative number" if n < 0
    (0..self).bsearch{|i| self - i**n }
  end

  def root_ceil(n)
    raise "Can't integer root negative number" if n < 0
    (0..self).bsearch{|i| i**n >= self }
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

  def self.generalized_chinese_remainder(remainders, mods)
    pairs = remainders.zip(mods)
    while pairs.size > 1
      r1,p1 = pairs.shift
      r2,p2 = pairs.shift
      g = p1.gcd(p2)
      if g == 1
        p3 = p1*p2
        r3 = chinese_remainder([r1,r2], [p1,p2])
      else
        if r1%g == r2%g
          p2z = p2/g
          r2z = r2%p2z
          p3 = p1*p2z
          r3 = chinese_remainder([r1,r2z], [p1,p2z])
        else
          return nil
        end
      end
      pairs.unshift([r3,p3])
    end
    pairs[0][0]
  end

  def self.chinese_remainder(remainders, mods)
    max = mods.reduce(:*)
    series = remainders.zip(mods).map{ |r,m| (r * max * (max/m).invmod(m) / m) }
    series.reduce(:+) % max
  end

  def discrete_log_linear(base, prime)
    target = self % prime
    base = base % prime
    max = prime - 1
    x = 1
    (0..max).each do |i|
      return i if x == self
      x = (x * base) % prime
    end
    # raise "Math doesn't work"
    nil
  end

  def discrete_log_bsgs(base, prime, max=prime-1)
    target = self % prime
    base = base % prime
    min = 0
    range_size = max-min+1
    s = Math.sqrt(range_size).round
    z = (range_size + s - 1) / s
    raise unless s*z >= range_size
    ht = {}
    gi = base.powmod(min, prime)
    s.times do |i|
      ht[gi] = min+i
      gi = (gi * base) % prime
    end
    gms = base.invmod(prime).powmod(s, prime)
    gj = target
    z.times do |j|
      if ht[gj]
        return ht[gj] + s * j
      end
      gj = (gj * gms) % prime
    end
    # raise "Math doesn't work"
    nil
  end

  def discrete_log_pohe(base, prime, factors)
    target = self % prime
    base = base % prime

    remainders = []
    mods = []
    factors.each do |pi, ei|
      pi_ei = pi**ei
      expi = (prime-1)/pi
      raise unless (prime-1) % pi == 0
      gi = base.powmod(expi, prime)
      if ei == 1
        hi = target.powmod(expi, prime)
        xi = hi.discrete_log_bsgs(gi, prime, pi-1)
      else
        xi = 0
        base_inv = base.invmod(prime)
        ei.times do |k|
          shiftexp = (prime-1) / (pi ** (k + 1))
          tmp_power = base_inv.powmod(shiftexp*xi, prime)
          zpower = (target.powmod(shiftexp, prime) * tmp_power) % prime
          lk = zpower.discrete_log_bsgs(gi, prime, pi-1) or return nil
          xi += lk * (pi ** k)
        end
      end
      return nil unless xi
      remainders << xi
      mods << pi_ei
    end
    Integer.chinese_remainder(remainders, mods)
  end
end
