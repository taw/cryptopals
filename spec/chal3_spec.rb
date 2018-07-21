describe Chal3 do
  let(:input) { "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736".unpack_hex }
  let(:cracked) { Chal3.new(input).call }

  it do
    expect(cracked).to eq([88, "Cooking MC's like a pound of bacon"])
  end
end
