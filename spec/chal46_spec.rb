describe Chal46 do
  let(:chal) { Chal46.new }
  let(:bits) { 512 }
  let(:p) { OpenSSL::BN.generate_prime(bits).to_i }
  let(:q) { OpenSSL::BN.generate_prime(bits).to_i }
  let(:n) { p * q }
  let(:e) { 0x10001 }
  let(:d) { chal.derive_d(p, q, e) }
  let(:pt) { Base64.decode64("VGhhdCdzIHdoeSBJIGZvdW5kIHlvdSBkb24ndCBwbGF5IGFyb3VuZCB3aXRoIHRoZSBGdW5reSBDb2xkIE1lZGluYQ==").to_hex.to_i(16) }
  let(:ct) { pt.powmod(e, n) }
  let(:box) { Chal46::Oracle.new(n,d) }
  let(:hacked) { chal.hack(n, e, ct, box) }

  it do
    expect(hacked).to eq(pt)
    expect(hacked.to_s(16).from_hex).to eq("That's why I found you don't play around with the Funky Cold Medina")
  end
end
