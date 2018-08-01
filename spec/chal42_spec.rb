describe Chal42 do
  describe RSA do
    let(:private_key1) { RSA.generate_key(e: 3, size: 384) }
    let(:private_key2) { RSA.generate_key(e: 0x10001, size: 256) }
    let(:public_key1) { private_key1.public_key }
    let(:public_key2) { private_key2.public_key }
    let(:msg1) { "Hello, world!" }
    let(:hash1) { Digest::SHA1.hexdigest(msg1) }
    let(:msg2) { "Goodbye, world!" }
    let(:hash2) { Digest::SHA1.hexdigest(msg2) }

    it "generates the right keys" do
      expect(private_key1.e).to eq(3)
      expect(private_key2.e).to eq(0x10001)
      expect(private_key1.n.to_s(2).size).to eq(384)
      expect(private_key2.n.to_s(2).size).to eq(256)
    end

    it "pads message correctly" do
      expect(private_key1.pad_message(msg1).to_s(16)).to eq("1ffffffffffffffffffffffffffffffffffffffffffffffffff00943a702d06f34599aee1f8da8ef9f7296031d699")
      expect(private_key2.pad_message(msg1).to_s(16)).to eq("1ffffffffffffffffff00943a702d06f34599aee1f8da8ef9f7296031d699")
    end

    it "signatures are deterministic" do
      expect(private_key1.sign(msg1)).to eq(private_key1.sign(msg1))
    end

    it "signs and verifies" do
      expect(public_key1.valid?(private_key1.sign(msg1), msg1)).to eq true
      expect(public_key1.valid?(private_key1.sign(msg2), msg1)).to eq false
      expect(public_key1.valid?(private_key2.sign(msg1), msg1)).to eq false
      expect(public_key1.valid?(private_key2.sign(msg2), msg1)).to eq false
      expect(public_key2.valid?(private_key1.sign(msg1), msg1)).to eq false
      expect(public_key2.valid?(private_key1.sign(msg2), msg1)).to eq false
      expect(public_key2.valid?(private_key2.sign(msg1), msg1)).to eq true
      expect(public_key2.valid?(private_key2.sign(msg2), msg1)).to eq false
      expect(public_key1.valid?(private_key1.sign(msg1), msg2)).to eq false
      expect(public_key1.valid?(private_key1.sign(msg2), msg2)).to eq true
      expect(public_key1.valid?(private_key2.sign(msg1), msg2)).to eq false
      expect(public_key1.valid?(private_key2.sign(msg2), msg2)).to eq false
      expect(public_key2.valid?(private_key1.sign(msg1), msg2)).to eq false
      expect(public_key2.valid?(private_key1.sign(msg2), msg2)).to eq false
      expect(public_key2.valid?(private_key2.sign(msg1), msg2)).to eq false
      expect(public_key2.valid?(private_key2.sign(msg2), msg2)).to eq true
    end

    it "signs and verifies" do
      expect(public_key1.kinda_valid?(private_key1.sign(msg1), msg1)).to eq true
      expect(public_key1.kinda_valid?(private_key1.sign(msg2), msg1)).to eq false
      expect(public_key1.kinda_valid?(private_key2.sign(msg1), msg1)).to eq false
      expect(public_key1.kinda_valid?(private_key2.sign(msg2), msg1)).to eq false
      expect(public_key2.kinda_valid?(private_key1.sign(msg1), msg1)).to eq false
      expect(public_key2.kinda_valid?(private_key1.sign(msg2), msg1)).to eq false
      expect(public_key2.kinda_valid?(private_key2.sign(msg1), msg1)).to eq true
      expect(public_key2.kinda_valid?(private_key2.sign(msg2), msg1)).to eq false
      expect(public_key1.kinda_valid?(private_key1.sign(msg1), msg2)).to eq false
      expect(public_key1.kinda_valid?(private_key1.sign(msg2), msg2)).to eq true
      expect(public_key1.kinda_valid?(private_key2.sign(msg1), msg2)).to eq false
      expect(public_key1.kinda_valid?(private_key2.sign(msg2), msg2)).to eq false
      expect(public_key2.kinda_valid?(private_key1.sign(msg1), msg2)).to eq false
      expect(public_key2.kinda_valid?(private_key1.sign(msg2), msg2)).to eq false
      expect(public_key2.kinda_valid?(private_key2.sign(msg1), msg2)).to eq false
      expect(public_key2.kinda_valid?(private_key2.sign(msg2), msg2)).to eq true
    end
  end
end
