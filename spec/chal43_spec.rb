describe Chal43 do
  let(:group) { DSA::Standard }
  describe DSA::Standard do
    it do
      expect(group).to be_valid
    end
  end

  describe "Sign and verify" do
    let(:private_key) { group.generate_key }
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
      expect(DSA::Signature.new(public_key, msg1, sig1.r, sig1.s)).to be_valid
      expect(DSA::Signature.new(public_key, msg1, sig2.r, sig1.s)).to_not be_valid
      expect(DSA::Signature.new(public_key, msg1, sig1.r, sig2.s)).to_not be_valid
      expect(DSA::Signature.new(public_key, msg1, sig2.r, sig2.s)).to_not be_valid
    end
  end
end
