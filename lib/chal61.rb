class Chal61
  def create_fake_ecda_signature_key(signature)
    group = signature.group
    curve = group.curve
    public_key = signature.public_key
    q = public_key.q
    g = group.g
    n = group.n
    s = signature.s
    r = signature.r
    msg = signature.msg
    h = ECDSA.hash(msg)
    inv_s = s.invmod(n)
    u1 = (h * inv_s) % n
    u2 = (r * inv_s) % n
    rr = curve.add( curve.multiply(g, u1), curve.multiply(q, u2) )

    new_d = rand(2...n)
    new_t = (u1 + u2*new_d) % n
    new_g = curve.multiply(rr, new_t.invmod(n))
    new_q = curve.multiply(new_g, new_d)

    new_group = ECDSA::Group.new(curve, new_g, n)
    new_private_key = ECDSA::PrivateKey.new(new_group, new_q, new_d)
    new_public_key = new_private_key.public_key
    new_signature = ECDSA::Signature.new(new_public_key, msg, r, s)

    [new_private_key, new_signature]
  end

  def generate_smooth_prime(factors, bitsize)
    min_prime = 2 ** (bitsize-1)
    # tries = 0
    while true
      p1 = 2
      while p1 < min_prime
        p1 *= factors.sample
      end
      # tries += 1
      if (p1+1).fast_prime?
        # puts "Found in #{tries} tries"
        return (p1+1)
      end
      # if tries % 10000 == 0
      #   puts "#{tries} tries"
      # end
    end
  end

  def generate_pair_of_smooth_primes(bitsize)
    p_factors, q_factors = Prime.take(2001).drop(1).each_slice(2).to_a.transpose
    [
      generate_smooth_prime(p_factors, bitsize),
      generate_smooth_prime(q_factors, bitsize),
    ]
  end
end
