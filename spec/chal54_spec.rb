describe Chal54 do
  let(:f) { Chal54::F.new }
  let(:nostradamus) { Chal54::Nostradamus.new(256) }
  let(:message) { "Ivanka Trump got #{rand(100_000_000..300_000_000)} votes in 2024 elections" }
  it do
    prediction_hash = nostradamus.prediction_hash
    prediction = nostradamus.create_prediction(message)
    expect(f.hexdigest(prediction)).to eq(prediction_hash)
  end
end
