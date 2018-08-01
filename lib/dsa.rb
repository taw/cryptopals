module DSA
  class Group < Struct.new(:p, :q, :g)
    def valid?
      raise "p is not prime" unless OpenSSL::BN.new(p).prime?
      raise "q is not prime" unless OpenSSL::BN.new(q).prime?
      raise "p-1 is not multiple of q" unless (p-1) % q == 0
      # Is this full test?
      raise "g is not q-order generator of Gp" unless 1 != g and g.powmod(q, p) == 1
      true
    end

    def generate_key
      x = rand(1...q)
      PrivateKey.new(self, x)
    end
  end

  class PrivateKey < Struct.new(:group, :x)
    def sign(msg)
      k = rand(2...group.q)
      h = DSA.hash(msg)
      100.times do
        r = group.g.powmod(k, group.p) % group.q
        s = (k.invmod(q) * (h + x*r)) % q
        next if r == 0 or s == 0
        return Signature.new(public_key, msg, r, s)
      end
      raise "Failed to generate signature too many times"
    end

    def p
      group.p
    end

    def q
      group.q
    end

    def g
      group.g
    end

    def y
      g.powmod(x, p)
    end

    def public_key
      PublicKey.new(group, y)
    end
  end

  class PublicKey < Struct.new(:group, :y)
    def p
      group.p
    end

    def q
      group.q
    end

    def g
      group.g
    end
  end

  class Signature < Struct.new(:public_key, :msg, :r, :s)
    def valid?
      return false unless 0 < r and r < q
      return false unless 0 < s and s < q
      w = s.invmod(q)
      u1 = h*w % q
      u2 = r*w % q
      v = ((g.powmod(u1, p) * y.powmod(u2, p)) % p) % q
      v == r
    end

    def h
      DSA.hash(msg)
    end

    def group
      public_key.group
    end

    def p
      public_key.p
    end

    def q
      public_key.q
    end

    def g
      public_key.g
    end

    def y
      public_key.y
    end
  end

  Standard = Group.new(
    %W[
      800000000000000089e1855218a0e7dac38136ffafa72eda7
      859f2171e25e65eac698c1702578b07dc2a1076da241c76c6
      2d374d8389ea5aeffd3226a0530cc565f3bf6b50929139ebe
      ac04f48c3c84afb796d61e5a4f9a8fda812ab59494232c7d2
      b4deb50aa18ee9e132bfa85ac4374d7f9091abc3d015efc87
      1a584471bb1
    ].join.to_i(16),
    %Q[f4f47f05794b256174bba6e9b396a7707e563c5b].to_i(16),
    %W[
      5958c9d3898b224b12672c0b98e06c60df923cb8bc999d119
      458fef538b8fa4046c8db53039db620c094c9fa077ef389b5
      322a559946a71903f990f1f7e0e025e2d7f7cf494aff1a047
      0f5b64c36b625a097f1651fe775323556fe00b3608c887892
      878480e99041be601a62166ca6894bdd41a7054ec89f756ba
      9fc95302291
    ].join.to_i(16),
  )

  class << self
    def hash(msg)
      Digest::SHA1.hexdigest(msg).to_i(16)
    end
  end
end
