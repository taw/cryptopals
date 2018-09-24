describe Chal62 do
  let(:prime) { 233970423115425145524320034830162017933 }
  let(:curve) { WeierstrassCurve.new(prime, -95051, 11279326) }
  let(:base_point) { [182, 85518893674295321206118380980485522083] }
  let(:base_point_order) { 29246302889428143187362802287225875743 }
  let(:group) { ECDSA::Group.new(curve, base_point, base_point_order) }

  let(:private_key) { Chal62::BiasedPrivateKey.generate_key(group) }
  let(:box) { Chal62::Box.new(private_key) }
  let(:attacker) { Chal62::Attacker.new(box) }

  describe "ECDSA sign and verify" do
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

  describe "#box" do
    let(:signatures) { 10.times.map{ box.call } }
    it do
      signatures.each do |signature|
        expect(signature).to be_valid
      end
      expect(signatures.uniq.size).to eq(10)
    end
  end

  describe "#signature_to_ut" do
    let(:signature) { box.call }
    let(:l) { 8 }
    let(:r) { signature.r }
    let(:s) { signature.s }
    let(:h) { signature.h }
    let(:q) { signature.group.n }

    it do
      u, t = attacker.signature_to_ut(signature)
      expect((t * s * 2**l) % q).to eq(r)
      expect((-u * s * 2**l) % q).to eq(h)
    end
  end

  describe "#collect_ut_pairs" do
    let(:uts) { attacker.collect_ut_pairs(20) }
    let(:l) { 8 }
    let(:q) { private_key.group.n }

    it do
      expect(uts.size).to eq(20)
      uts.each do |signature, u, t|
        r = signature.r
        s = signature.s
        h = signature.h
        expect((t * s * 2**l) % q).to eq(r)
        expect((-u * s * 2**l) % q).to eq(h)
      end
    end
  end

  # attack
  pending
end
