describe Chal30 do
  let(:chal) { Chal30.new }
  let(:secret_size) { 24 }
  let(:msg) { "comment1=cooking%20MCs;userdata=foo;comment2=%20like%20a%20pound%20of%20bacon" }
  let(:box) { Chal30::Box.new(secret_size) }
  let(:mac) { box.sign(msg) }

  describe "MD4" do
    let(:msg) { "All your base are belong to us" }
    let(:digest) { Chal30::MD4.new.md4(msg) }
    let(:digest_ruby) { OpenSSL::Digest::MD4.hexdigest(msg) }
    it do
      expect(digest).to eq(digest_ruby)
    end
  end

  describe "valid?" do
    it do
      expect(box.valid?(msg, mac)).to eq(true)
    end
  end

  describe "hack" do
    let(:final) {  ";admin=true" }
    it do
      hacked_msg, hacked_mac = chal.hack(secret_size, msg, mac, final)
      expect(hacked_msg.end_with?(final)).to eq(true)
      expect(box.valid?(hacked_msg, hacked_mac)).to eq(true)
    end
  end
end
