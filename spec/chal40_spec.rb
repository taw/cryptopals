describe Chal40 do
  let(:chal) { Chal40.new }
  let(:rsa1) { Chal39.generate_key(512, 3).public_key }
  let(:rsa2) { Chal39.generate_key(512, 3).public_key }
  let(:rsa3) { Chal39.generate_key(512, 3).public_key }
  let(:msg) { "All your base are belong to us. Internet is made of cats.".to_hex.to_i(16) }

  let(:encrypted1) { rsa1.encrypt(msg) }
  let(:encrypted2) { rsa2.encrypt(msg) }
  let(:encrypted3) { rsa3.encrypt(msg) }

  it do
    # Test that they're actually different, otherwise it's trivial
    expect([encrypted1, encrypted2, encrypted3].uniq.size).to eq(3  )
    expect(chal.decrypt([rsa1, rsa2, rsa3], [encrypted1, encrypted2, encrypted3])).to eq(msg)
  end
end
