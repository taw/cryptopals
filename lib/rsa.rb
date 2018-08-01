module RSA
  class PrivateKey < Struct.new(:n, :e, :d)
    def signature_size
      n.to_s(2).size / 8
    end

    def sign
      pad_message(msg).powmod(d, n)
    end

    def public_key
      PublicKey.new(n, e)
    end

    def pad_message(msg)
      hash = Digest::SHA1.hexdigest(msg)
      ffs = signature_size - hash.size/2 - 3
      ("0001" + "ff" * ffs + "00" + hash).to_i(16)
    end
  end

  class PublicKey < Struct.new(:n, :e)
    def valid?(signature, msg)
      raise "Signature too big" if signature > n
      raise "Signature too small" if signature * (2 ** 16) < n
      decoded = signature.powmod(d, n)
      hash = Digest::SHA1.hexdigest(msg)
      ffs = signature_size - hash.size/2 - 3
      expected = "0001" + "ff" * ffs + "00" + hash
      expected == decoded
    end

    def kinda_valid?(signature, msg)
      raise "Signature too big" if signature > n
      raise "Signature too small" if signature * (2 ** 16) < n
      binding.pry
    end
  end

  class << self
    def generate_key(size:, e:)
      p = OpenSSL::BN.generate_prime(size / 2).to_i
      q = OpenSSL::BN.generate_prime(size / 2).to_i
      n = p * q
      d = e.invmod((p-1)*(q-1))
      PrivateKey.new(n, e, d)
    end
  end
end
