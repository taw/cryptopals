describe Chal17 do
  let(:chal) { Chal17.new }
  let(:box) { Chal17::Box.new }
  let(:guess) { chal.hack(box) }

  it do
    expect(box.hacked?(guess)).to eq(true)
  end
end
