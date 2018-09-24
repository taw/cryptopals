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
end
