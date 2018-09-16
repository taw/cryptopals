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

  # Avoid duplicates as they make the rest of he code code more complicated
  def generate_smooth_prime(factors, bitsize)
    factors -= [2] # Just to be sure
    min_prime = 2 ** (bitsize-1)
    # tries = 0
    while true
      p1 = 2
      seen_factors = Set[]

      while p1 < min_prime
        u = factors.sample
        next if seen_factors.include?(u)
        p1 *= u
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

  def create_fake_rsa_signature_key(signature, msg, public_key)
    padded_message = public_key.pad_message_for_signing(msg)
    bitsize = public_key.signature_size * 8 / 2
    p, q = generate_pair_of_smooth_primes(bitsize)
    p1factors = (p-1).prime_division.map(&:first)
    q1factors = (q-1).prime_division.map(&:first)
  end
end
