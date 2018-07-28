describe Chal27 do
  let(:chal) { Chal27.new }
  let(:key) { AES.random_key }
  let(:box) { Chal27::Box.new(key) }

  it do
    expect(chal.hack(box)).to eq(key)
  end
end
