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

  describe "hack" do
    let(:chal) { Chal43.new }
    let(:y) {
      %W[84ad4719d044495496a3201c8ff484feb45b962e7302e56a392aee4
      abab3e4bdebf2955b4736012f21a08084056b19bcd7fee56048e004
      e44984e2f411788efdc837a0d2e5abb7b555039fd243ac01f0fb2ed
      1dec568280ce678e931868d23eb095fde9d3779191b8c0299d6e07b
      bb283e6633451e535c45513b2d33c99ea17].join.to_i(16)
    }
    let(:public_key) { DSA::PublicKey.new(DSA::Standard, y) }
    let(:msg) { "For those that envy a MC it can be hazardous to your health\nSo be friendly, a matter of life and death, just like a etch-a-sketch\n" }
    let(:r) { 548099063082341131477253921760299949438196259240 }
    let(:s) { 857042759984254168557880549501802188789837994940 }
    let(:signature) { DSA::Signature.new(public_key, msg, r, s)  }
    let(:h) { 0xd2d0714f014a9784047eaeccf956520045c45265 }

    it do
      expect(DSA.hash(msg)).to eq(h)
      private_key = chal.hack(signature)
      expect(private_key.public_key).to eq(public_key)
    end
  end
end
