describe Chal5 do
  let(:input) {
    "Burning 'em, if you ain't quick and nimble\n" +
    "I go crazy when I hear a cymbal"
  }
  let(:key) { "ICE" }
  let(:output) {
    "0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272" +
    "a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"
  }

  it do
    expect(Chal5.new.call(input, key).to_hex).to eq(output)
  end
end
