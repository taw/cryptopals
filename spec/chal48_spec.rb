describe Chal48 do
  let(:bits) { 384 }
  let(:p) { OpenSSL::BN.generate_prime(bits).to_i }
  let(:q) { OpenSSL::BN.generate_prime(bits).to_i }
  let(:n) { p*q }
  let(:e) { 0x10001 }
  let(:d) { e.invmod((p-1)*(q-1)) }
  let(:private_key) { RSA::PrivateKey.new(n, e, d) }
  let(:public_key) { private_key.public_key }

  let(:msg) { "kick it, CC" }
  let(:nlen) { Chal47.pad_len_for_key(public_key.n) }
  let(:padded) { Chal47.pad(msg, nlen) }

  let(:oracle) { Chal48::Oracle.new(private_key) }
  let(:encrypted_correct) { public_key.encrypt(padded.to_i_binary) }

  describe "attack" do
    let(:attacker) { Chal48::Attacker.new(public_key, oracle) }

    it do
      decoded = attacker.call(encrypted_correct)
      expect(decoded).to eq(msg)
    end
  end
end
