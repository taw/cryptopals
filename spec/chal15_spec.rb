describe Chal15 do
  let(:chal) { Chal15.new }

  it do
    expect(chal.strip_padding("ICE ICE BABY\x04\x04\x04\x04")).to eq("ICE ICE BABY")
    expect{ chal.strip_padding("ICE ICE BABY\x05\x05\x05\x05") }.to raise_error("Bad padding")
    expect{ chal.strip_padding("ICE ICE BABY\x01\x02\x03\x04") }.to raise_error("Bad padding")
  end
end
