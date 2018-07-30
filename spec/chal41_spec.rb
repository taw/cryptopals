describe Chal41 do
  let(:chal) { Chal41.new }
  let(:bits) { 512 }
  let(:p) { OpenSSL::BN.generate_prime(bits).to_i }
  let(:q) { OpenSSL::BN.generate_prime(bits).to_i }
  let(:n) { p * q }
  let(:e) { 0x10001 }
  let(:d) { chal.derive_d(p, q, e) }
  let(:pt) { rand(1..n-1) }
  let(:ct) { pt.powmod(e, n) }

  let(:box) { Chal41::Box.new(n, e, d) }

  it do
    expect(box.decode(ct)).to eq(pt)
    expect{box.decode(ct)}.to raise_error("Can't decode twice")
    expect(chal.hack(box, ct)).to eq(pt)
  end
end
