describe Chal42 do
  describe RSA do
    let(:private_key1) { RSA.generate_key(e: 3, size: 384) }
    let(:private_key2) { RSA.generate_key(e: 0x10001, size: 256) }
    let(:public_key1) { private_key1.public_key }
    let(:public_key2) { private_key2.public_key }
    let(:msg) { "Hello, world!" }
    let(:hash) { Digest::SHA1.hexdigest(msg) }

    it "generates the right keys" do
      expect(private_key1.e).to eq(3)
      expect(private_key2.e).to eq(0x10001)
      expect(private_key1.n.to_s(2).size).to eq(384)
      expect(private_key2.n.to_s(2).size).to eq(256)
    end

    it "pads message correctly" do
      expect(private_key1.pad_message(msg).to_s(16)).to eq("1ffffffffffffffffffffffffffffffffffffffffffffffffff00943a702d06f34599aee1f8da8ef9f7296031d699")
      expect(private_key2.pad_message(msg).to_s(16)).to eq("1ffffffffffffffffff00943a702d06f34599aee1f8da8ef9f7296031d699")
    end
  end
end
