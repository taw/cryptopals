describe Chal7 do
  let(:sample_path) { Pathname("#{__dir__}/data/7.txt") }
  let(:sample) { Base64.decode64(sample_path.read) }
  let(:key) { "YELLOW SUBMARINE" }

  it do
    expect(Chal7.new.decode(sample, key)).to match(/Play that funky music/)
  end
end
