describe Chal62 do
  let(:prime) { 233970423115425145524320034830162017933 }
  let(:curve) { WeierstrassCurve.new(prime, -95051, 11279326) }
  let(:base_point) { [182, 85518893674295321206118380980485522083] }
  let(:base_point_order) { 29246302889428143187362802287225875743 }
  let(:group) { ECDSA::Group.new(curve, base_point, base_point_order) }

  describe "ECDSA sign and verify" do
    let(:private_key) { Chal62::BiasedPrivateKey.generate_key(group) }
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

  # attack
  pending
end
