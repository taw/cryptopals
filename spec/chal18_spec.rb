describe Chal18 do
  let(:str) { Base64.decode64("L77na/nrFsKvynd6HzOoG7GHTLXsTVu9qvY/2syLXzhPweyyMTJULu/6/kXX0KSvoOLSFQ==") }
  let(:chal) { Chal18.new }
  let(:key) { "YELLOW SUBMARINE" }
  let(:nonce) { 0 }

  describe "#counter_block" do
    it do
      expect(chal.counter_block(0, 0)).to eq(
        "\x00\x00\x00\x00\x00\x00\x00\x00".b + "\x00\x00\x00\x00\x00\x00\x00\x00".b)
      expect(chal.counter_block(2, 1)).to eq(
        "\x02\x00\x00\x00\x00\x00\x00\x00".b + "\x01\x00\x00\x00\x00\x00\x00\x00".b)
      expect(chal.counter_block(0x08_07_06_05_04_03_02_01, 0x11_22_33_44_55_66_77_88)).to eq(
        "\x01\x02\x03\x04\x05\x06\x07\x08".b + "\x88\x77\x66\x55\x44\x33\x22\x11".b)
    end
  end

  describe "#keystream" do
    it do
      expect(chal.keystream(key, nonce, 0)).to eq(
        AES.encrypt_block("\x00\x00\x00\x00\x00\x00\x00\x00".b + "\x00\x00\x00\x00\x00\x00\x00\x00".b, key))
      expect(chal.keystream(key, nonce, 1)).to eq(
        AES.encrypt_block("\x00\x00\x00\x00\x00\x00\x00\x00".b + "\x01\x00\x00\x00\x00\x00\x00\x00".b, key))
      expect(chal.keystream(key, 0x08_07_06_05_04_03_02_01, 0x11_22_33_44_55_66_77_88)).to eq(
        AES.encrypt_block("\x01\x02\x03\x04\x05\x06\x07\x08".b + "\x88\x77\x66\x55\x44\x33\x22\x11".b, key))
    end
  end

  describe "#decode" do
    it do
      expect(chal.decode(str, key, nonce)).to eq("Yo, VIP Let's kick it Ice, Ice, baby Ice, Ice, baby ")
    end
  end
end
