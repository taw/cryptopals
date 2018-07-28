describe Chal28 do
  let(:chal) { Chal28.new }
  let(:key) { "MUCH SECRET VERY SECURE" }
  let(:msg) { "All your base are belong to us" }
  let(:mac) { chal.mac(key, msg) }
  let(:mac_ruby) { Digest::SHA1.hexdigest(key+msg) }

  it do
    expect(mac).to eq(mac_ruby)
  end
end
