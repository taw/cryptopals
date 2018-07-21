describe Chal2 do
  let(:input) { "1c0111001f010100061a024b53535009181c".unpack_hex }
  let(:key) { "686974207468652062756c6c277320657965".unpack_hex }
  let(:output) { "746865206b696420646f6e277420706c6179".unpack_hex }

  it do
    expect(Chal2.call(input, key)).to eq(output)
  end
end

