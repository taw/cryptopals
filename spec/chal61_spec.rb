describe Chal61 do
  let(:chal) { Chal61.new }

  describe "ECDSA attack" do
    let(:prime) { 233970423115425145524320034830162017933 }
    let(:curve) { WeierstrassCurve.new(prime, -95051, 11279326) }
    let(:base_point) { [182, 85518893674295321206118380980485522083] }
    let(:base_point_order) { 29246302889428143187362802287225875743 }
    let(:group) { ECDSA::Group.new(curve, base_point, base_point_order) }

    describe "ECDSA sign and verify" do
      let(:private_key) { ECDSA::PrivateKey.generate_key(group) }
      let(:public_key) { private_key.public_key }
      let(:msg1) { "Hello world!" }
      let(:msg2) { "Goodbye world!" }
      let(:sig1) { private_key.sign(msg1) }
      let(:sig2) { private_key.sign(msg2) }

      it "real ones" do
        expect(sig1).to be_valid
        expect(sig2).to be_valid
      end

      it "some fake ones" do
        expect(ECDSA::Signature.new(public_key, msg1, sig1.r, sig1.s)).to be_valid
        expect(ECDSA::Signature.new(public_key, msg1, sig2.r, sig1.s)).to_not be_valid
        expect(ECDSA::Signature.new(public_key, msg1, sig1.r, sig2.s)).to_not be_valid
        expect(ECDSA::Signature.new(public_key, msg1, sig2.r, sig2.s)).to_not be_valid
      end
    end

    describe "ECDSA hack - create_fake_ecda_signature_key" do
      let(:private_key) { ECDSA::PrivateKey.generate_key(group) }
      let(:public_key) { private_key.public_key }
      let(:msg) { "Hello world!" }
      let(:legit_signature) { private_key.sign(msg) }

      # New key, on same curve but with different valid generator
      it do
        private_key, hacked_signature = chal.create_fake_ecda_signature_key(legit_signature)
        public_key = hacked_signature.public_key
        # It is valid
        expect(hacked_signature).to be_valid

        # We control it
        expect(hacked_signature.public_key).to eq(private_key.public_key)

        # It's mostly matching
        expect(hacked_signature.r).to eq(legit_signature.r)
        expect(hacked_signature.s).to eq(legit_signature.s)
        expect(hacked_signature.msg).to eq(legit_signature.msg)
        expect(hacked_signature.public_key.curve).to eq(legit_signature.public_key.curve)
        expect(hacked_signature.public_key.n).to eq(legit_signature.public_key.n)

        # Differences
        expect(hacked_signature.public_key).to_not eq(legit_signature.public_key)
        expect(hacked_signature.public_key.g).to_not eq(legit_signature.public_key.g)
        expect(hacked_signature.public_key.q).to_not eq(legit_signature.public_key.q)

        # It is still a generator
        expect(public_key.curve.multiply(public_key.g, public_key.n)).to eq(:infinity)
      end
    end
  end

  describe "RSA attack" do
    describe "generate_smooth_prime" do
      let(:bits) { 256 }
      let(:factors) { Prime.take(1000) }
      let(:prime) { chal.generate_smooth_prime(factors, bits) }
      let(:smooth_factors) { (prime-1).prime_division.map(&:first) }

      it do
        expect(prime).to be_fast_prime
        expect(smooth_factors.all?{|x| x < 10_000}).to be true
      end
    end

    describe "generate_pair_of_smooth_primes" do
      let(:bits) { 256 }
      let(:factors) { Prime.take(1001).drop(1) }
      let(:pq) { chal.generate_pair_of_smooth_primes(bits) }
      let(:p) { pq[0] }
      let(:q) { pq[1] }
      let(:p_smooth_factors) { (p-1).prime_division.map(&:first) }
      let(:q_smooth_factors) { (q-1).prime_division.map(&:first) }

      it do
        expect(p).to be_fast_prime
        expect(q).to be_fast_prime
        expect(p_smooth_factors.all?{|x| x < 20_000}).to be true
        expect(q_smooth_factors.all?{|x| x < 20_000}).to be true
        expect(p_smooth_factors & q_smooth_factors).to eq([2])
      end
    end

    describe "attack" do
      let(:private_key) { RSA.generate_key(size: 512, e: 0x10001) }
      let(:public_key) { private_key.public_key }
      let(:msg) { "Hello world!" }
      let(:signature) { private_key.sign(msg) }
      let(:padded_message) { public_key.pad_message_for_signing(msg) }

      it do
        hacked_private_key = chal.create_fake_rsa_signature_key(signature, msg, public_key)

        e = hacked_private_key.e
        n = hacked_private_key.n
        d = hacked_private_key.d
        s = signature
        m = padded_message

        s2 = m.powmod(d, n)
        m2 = s.powmod(e, n)

        expect(private_key.public_key.valid?(signature, msg)).to be true
        expect(hacked_private_key.public_key.valid?(signature, msg)).to be true
        expect(hacked_private_key.public_key).to_not eq(private_key.public_key)
        expect(hacked_private_key.decrypt(padded_message)).to eq(signature)
      end
    end
  end
end
