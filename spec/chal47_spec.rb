describe Chal47 do
  let(:bits) { 128 }
  let(:p) { OpenSSL::BN.generate_prime(bits).to_i }
  let(:q) { OpenSSL::BN.generate_prime(bits).to_i }
  let(:n) { p*q }
  let(:e) { 0x10001 }
  let(:d) { e.invmod((p-1)*(q-1)) }
  let(:private_key) { RSA::PrivateKey.new(n, e, d) }
  let(:public_key) { private_key.public_key }

  let(:msg) { msg = "kick it, CC" }
  let(:padded) { Chal47.pad(msg, 32) }
  let(:correctly_padded) { "\x00\x02\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00kick it, CC".b }
  let(:somewhat_correctly_padded) { "\x00\x02\xFE\xED\xFE\xED\xFE\xED\xFE\xED\xFE\xED\xFE\xED\xFE\xED\xFE\xED\xFE\xED\x00kick it, CC".b }
  let(:incorrectly_padded) { "\x00\x03\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00kick it, CC".b }

  describe "PKCS#1 v1.5" do
    it "pad_len_for_key" do
      expect(Chal47.pad_len_for_key(n)).to eq(32)
    end

    it "pad" do
      expect(padded).to eq(correctly_padded)
    end

    it "correct_padding?" do
      expect(Chal47.correct_padding?(correctly_padded, 32)).to eq(true)
      expect(Chal47.correct_padding?(somewhat_correctly_padded, 32)).to eq(false)
      expect(Chal47.correct_padding?(incorrectly_padded, 32)).to eq(false)
    end

    it "somewhat_correct_padding?" do
      expect(Chal47.somewhat_correct_padding?(correctly_padded, 32)).to eq(true)
      expect(Chal47.somewhat_correct_padding?(somewhat_correctly_padded, 32)).to eq(true)
      expect(Chal47.somewhat_correct_padding?(incorrectly_padded, 32)).to eq(false)
    end
  end

  describe "oracle" do
    let(:oracle) { Chal47::Oracle.new(private_key) }
    let(:encrypted_correct) { public_key.encrypt(correctly_padded.to_i_binary) }
    let(:encrypted_incorrect) { public_key.encrypt(incorrectly_padded.to_i_binary) }
    let(:encrypted_somewhat_incorrect) { public_key.encrypt(somewhat_correctly_padded.to_i_binary) }

    it do
      expect(oracle.call(encrypted_correct)).to eq(true)
      expect(oracle.call(encrypted_incorrect)).to eq(false)
      # This is why attack works:
      expect(oracle.call(encrypted_somewhat_incorrect)).to eq(true)
    end
  end

  describe "attack" do
    let(:chal) { Chal47.new }

    # hack
    pending
  end
end
