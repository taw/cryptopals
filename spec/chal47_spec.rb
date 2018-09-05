describe Chal47 do
  let(:chal) { Chal47.new }
  let(:bits) { 128 }
  let(:p) { OpenSSL::BN.generate_prime(bits).to_i }
  let(:q) { OpenSSL::BN.generate_prime(bits).to_i }
  let(:n) { p*q }
  let(:e) { 0x10001 }
  let(:d) { e.invmod((p-1)*(q-1)) }

  describe "PKCS#1 v1.5" do
    let(:msg) { msg = "kick it, CC" }
    let(:padded) { chal.pad(msg, 32) }
    let(:correctly_padded) { "\x00\x02\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00kick it, CC".b }
    let(:somewhat_correctly_padded) { "\x00\x02\xFE\xED\xFE\xED\xFE\xED\xFE\xED\xFE\xED\xFE\xED\xFE\xED\xFE\xED\xFE\xED\x00kick it, CC".b }
    let(:incorrectly_padded) { "\x00\x03\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00kick it, CC".b }

    it "pad_len_for_key" do
      expect(chal.pad_len_for_key(n)).to eq(32)
    end

    it "pad" do
      expect(padded).to eq(correctly_padded)
    end

    it "correct_padding?" do
      expect(chal.correct_padding?(correctly_padded, 32)).to eq(true)
      expect(chal.correct_padding?(somewhat_correctly_padded, 32)).to eq(false)
      expect(chal.correct_padding?(incorrectly_padded, 32)).to eq(false)
    end

    it "somewhat_correct_padding?" do
      expect(chal.somewhat_correct_padding?(correctly_padded, 32)).to eq(true)
      expect(chal.somewhat_correct_padding?(somewhat_correctly_padded, 32)).to eq(true)
      expect(chal.somewhat_correct_padding?(incorrectly_padded, 32)).to eq(false)
    end
  end

  # hack
  pending
end
