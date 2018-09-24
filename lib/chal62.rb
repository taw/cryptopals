class Chal62
  class BiasedPrivateKey < ECDSA::PrivateKey
    def sign(msg)
      k = rand(2...n) & ~0xff
      h = ECDSA.hash(msg)
      r = curve.multiply(g, k)[0] % n
      s = ((h + d*r) * k.invmod(n)) % n
      ECDSA::Signature.new(public_key, msg, r, s)
    end
  end

  class Box
    def initialize(private_key)
      @private_key = private_key
    end

    def random_message
      Random::DEFAULT.bytes(32)
    end

    def call
      @private_key.sign(random_message)
    end
  end

  class Attacker
    def initialize(box)
      @box = box
    end

    def signature_to_ut(signature)
      l = 8
      q = signature.group.n
      s = signature.s
      r = signature.r
      h = signature.h

      s2l = (s * (2**l)) % q
      t = r.divide_modulo(s2l, q)
      u = h.divide_modulo(-s2l, q)
      [u, t]
    end

    def collect_ut_pairs(count)
      count.times.map{
        signature = @box.call
        [signature, *signature_to_ut(signature)]
      }
    end
  end
end
