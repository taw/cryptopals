describe Chal25 do
  let(:chal) { Chal25.new }
  let(:samples_path) { Pathname("#{__dir__}/data/25.txt") }
  let(:secret) { AES.decrypt_ecb(Base64.decode64(samples_path.read), "YELLOW SUBMARINE") }
  let(:box) { Chal25::Box.new(4096) }

  it do
    box.write(0, secret)
    old_disk = box.disk.dup
    result = chal.hack(box)
    expect(box.disk).to eq(old_disk)
    expect(result[0, secret.size]).to eq(secret)
    expect(result).to match(/Play that funky music/)
  end
end
