class Chal41
  def derive_d(p, q, e)
    e.invmod((p-1)*(q-1))
  end

  class Box
    attr_reader :n, :e

    def initialize(n, e, d)
      @n = n
      @e = e
      @d = d
      @seen = {}
    end

    def decode(ct)
      raise "Can't decode twice" if @seen[ct]
      @seen[ct] = true
      ct.powmod(@d, @n)
    end
  end

  def hack(box, c_msg)
    e = box.e
    n = box.n
    k = rand(2..n-1)
    c_k = k.powmod(e, n)
    c_k_msg = (c_k * c_msg) % n
    p_k_msg = box.decode(c_k_msg)
    p_msg = (p_k_msg * k.invmod(n)) % n
  end
end
