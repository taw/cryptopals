describe Chal9 do
  let(:input) { "YELLOW SUBMARINE".b }
  let(:padded) { "YELLOW SUBMARINE\x04\x04\x04\x04".b }

  it do
    expect(Chal9.new.call(input, 20)).to eq(padded)
  end
end
