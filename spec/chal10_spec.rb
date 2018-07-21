describe Chal10 do
  let(:sample_path) { Pathname("#{__dir__}/data/10.txt") }
  let(:sample) { Base64.decode64(sample_path.read) }

  let(:key) { "YELLOW SUBMARINE" }
  let(:iv) { "\x00".b * 16 }

  let(:decoded) { Chal10.new.decode(sample, key, iv) }

  it do
    expect(decoded).to match(/Play that funky music/)
  end
end
