describe XorCracker do
  let(:input) { "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736".unpack_hex }
  let(:cracked) { XorCracker.new(input).call }

  it do
    expect(cracked).to eq("Cooking MC's like a pound of bacon")
  end
end
