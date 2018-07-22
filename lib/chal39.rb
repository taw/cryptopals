class Chal39
  attr_reader :n, :e, :d

  def initialize(n, e, d=nil)
    @n = n
    @e = e
    @d = d
  end

  def encrypt(msg)
    msg.powmod(@e, @n)
  end

  def decrypt(msg)
    raise "Trying to decrypt with public key does not work" unless @d
    msg.powmod(@d, @n)
  end

  def public_key
    self.class.new(@n, @e)
  end

  class << self
    def generate_key(bits, e)
      p = OpenSSL::BN.generate_prime(bits).to_i
      q = OpenSSL::BN.generate_prime(bits).to_i
      n = p * q
      d = derive_d(e, p, q)
      new(n, e, d)
    end

    def derive_d(e, p, q)
      e.invmod((p-1)*(q-1))
    end
  end
end
