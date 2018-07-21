describe Chal11 do
  let(:chal) { Chal11.new }

  it "detects ECB" do
    16.times do
      box = chal.ecb_box
      expect(chal.oracle(box)).to eq(:ecb)
    end
  end

  it "detects CBC" do
    16.times do
      box = chal.cbc_box
      expect(chal.oracle(box)).to eq(:cbc)
    end
  end
end
