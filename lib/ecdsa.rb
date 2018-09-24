module ECDSA
  class Group < Struct.new(:curve, :g, :n)
  end

  class PrivateKey < Struct.new(:group, :q, :d)
    def public_key
      PublicKey.new(group, q)
    end

    def g
      group.g
    end

    def n
      group.n
    end

    def curve
      group.curve
    end

    def sign(msg)
      k = rand(2...n)
      h = ECDSA.hash(msg)
      r = curve.multiply(g, k)[0] % n
      s = ((h + d*r) * k.invmod(n)) % n
      Signature.new(public_key, msg, r, s)
    end

    def self.generate_key(group)
      curve = group.curve
      g = group.g
      n = group.n
      d = rand(2...n)
      new(group, curve.multiply(g, d), d)
    end
  end

  class PublicKey < Struct.new(:group, :q)
    def curve
      group.curve
    end

    def g
      group.g
    end

    def n
      group.n
    end
  end

  class Signature < Struct.new(:public_key, :msg, :r, :s)
    def group
      public_key.group
    end

    def n
      group.n
    end

    def curve
      group.curve
    end

    def q
      public_key.q
    end

    def g
      public_key.g
    end

    def valid?
      return false unless 0 < r and r < n
      return false unless 0 < s and s < n
      inv_s = s.invmod(n)
      u1 = (h * inv_s) % n
      u2 = (r * inv_s) % n
      rr = curve.add( curve.multiply(g, u1), curve.multiply(q, u2) )[0] % n
      rr == r
    end

    def h
      ECDSA.hash(msg)
    end
  end

  class << self
    def hash(msg)
      # 120 bit
      Digest::SHA1.hexdigest(msg).to_i(16) & 0xffffffffffffffffffffffffffffff
    end
  end
end
