describe Chal39 do
  describe "#invmod" do
    it do
       expect(17.invmod(3120)).to eq(2753)
    end
  end

  describe "RSA" do
    # Not much of a test
    let(:msg) { 42 }
    let(:e) { 0x10001 }
    it do
      private_key = Chal39.generate_key(512, e)
      public_key = private_key.public_key
      ciphertext = public_key.encrypt(msg)
      expect(ciphertext).to eq((msg ** e) % public_key.n)
      expect(private_key.decrypt(ciphertext)).to eq(msg)
    end
  end
end
