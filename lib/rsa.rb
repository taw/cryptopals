module RSA
  class PrivateKey < Struct.new(:n, :e, :d)
    def signature_size
      n.to_s(2).size / 8
    end

    def sign(msg)
      pad_message_for_signing(msg).powmod(d, n)
    end

    def public_key
      PublicKey.new(n, e)
    end

    def pad_message_for_signing(msg)
      hash = Digest::SHA1.hexdigest(msg)
      ffs = signature_size - hash.size/2 - 3
      ("0001" + "ff" * ffs + "00" + hash).to_i(16)
    end

    def decrypt(msg)
      msg.powmod(d, n)
    end
  end

  class PublicKey < Struct.new(:n, :e)
    # These two methods are for both keys
    def signature_size
      n.to_s(2).size / 8
    end

    def pad_message_for_signing(msg)
      hash = Digest::SHA1.hexdigest(msg)
      ffs = signature_size - hash.size/2 - 3
      ("0001" + "ff" * ffs + "00" + hash).to_i(16)
    end

    def valid?(signature, msg)
      if signature > n
        return false
        # Definitely too big
      end
      decoded = signature.powmod(e, n)
      hash = Digest::SHA1.hexdigest(msg)
      ffs = signature_size - hash.size/2 - 3
      expected = "0001" + "ff" * ffs + "00" + hash
      expected.to_i(16) == decoded
    end

    # This is the vulnerable algorithm
    def kinda_valid?(signature, msg)
      if signature > n
        return false
        # Definitely too big
      end
      decoded = "000" + signature.powmod(e, n).to_s(16)
      return false unless decoded.size.even?
      decoded = decoded.from_hex.bytes
      return false unless decoded.shift == 0
      return false unless decoded.shift == 1
      decoded.shift while decoded[0] == 255
      return false unless decoded.shift == 0
      hash = Digest::SHA1.hexdigest(msg)
      hash == decoded.pack("C*").to_hex[0,40]
    end

    def encrypt(msg)
      msg.powmod(e, n)
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
