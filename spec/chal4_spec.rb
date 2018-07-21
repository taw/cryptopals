describe Chal4 do
  let(:samples_path) { Pathname("#{__dir__}/data/4.txt") }
  let(:samples) { samples_path.readlines.map(&:chomp).map(&:unpack_hex) }

  it do
    decoded, sample = Chal4.new(samples).call

    expect(decoded).to eq("Now that the party is jumping\n")
    expect(sample.pack_hex).to eq("7b5a4215415d544115415d5015455447414c155c46155f4058455c5b523f")
  end
end
