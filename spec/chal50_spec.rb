describe Chal50 do
  let(:chal) { Chal50.new }
  let(:msg) { "alert('MZA who was that?');\n" }
  let(:key) { "YELLOW SUBMARINE" }
  let(:iv) { ("%032x" % 0).from_hex }
  let(:hash) { "296b8d7cb78a243dda4d0a61d33bbdd1" }

  it do
    expect(chal.cbc_mac(msg, key, iv)).to eq(hash)
  end
end
