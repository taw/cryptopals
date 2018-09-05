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
end
