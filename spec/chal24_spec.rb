describe Chal24 do
  let(:chal) { Chal24.new }
  describe "Cipher" do
    let(:cipher) { Chal24::Cipher.new(Time.now.to_i) }
    let(:message) { "All your base are belong to us." }
    it do
      expect(cipher.decrypt(cipher.encrypt(message))).to eq(message)
    end
  end

  describe "hack" do
    let(:plaintext) { rand(10..100).times.map{ rand(256) }.pack("C*") + "A" * 14  }
    let(:key) { Time.now.to_i + rand(-2**15..2**15) }
    let(:cipher) { Chal24::Cipher.new(key) }
    let(:ciphertext) { cipher.encrypt(plaintext) }
    it do
      expect(chal.hack(ciphertext)).to eq(key)
    end
  end
end
