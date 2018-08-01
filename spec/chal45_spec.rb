describe Chal45 do
  let(:msg1) { "Hello, world" }
  let(:msg2) { "Goodbye, world" }
  let(:private_key) { group.generate_key }
  let(:public_key) { private_key.public_key }

  describe "g=0" do
    let(:group) { Chal45::Group0 }
    it do
      expect{ private_key.sign(msg1) }.to raise_error("Failed to generate signature too many times")
    end
  end

  describe "g=p+1" do
    let(:group) { Chal45::GroupP1 }
    let(:sig1) { private_key.sign(msg1) }
    let(:sig2) { private_key.sign(msg2) }

    it do
      expect(sig1).to be_valid
      expect(sig2).to be_valid
    end

    it "some fake ones still passing" do
      expect(DSA::Signature.new(public_key, msg1, sig1.r, sig1.s)).to be_valid
      expect(DSA::Signature.new(public_key, msg1, sig2.r, sig1.s)).to be_valid
      expect(DSA::Signature.new(public_key, msg1, sig1.r, sig2.s)).to be_valid
      expect(DSA::Signature.new(public_key, msg1, sig2.r, sig2.s)).to be_valid
    end
  end
end
