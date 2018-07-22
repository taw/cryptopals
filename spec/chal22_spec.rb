describe Chal22 do
  let(:chal) { Chal22.new }
  let(:rng) { Chal21.new.tap{|rng| rng.seed(seed)} }
  let(:seed) { Time.now.to_i + rand(-100..100) }

  it do
    value = rng.extract_number
    expect(chal.hack(Time.now.to_i, value)).to eq(seed)
  end
end
