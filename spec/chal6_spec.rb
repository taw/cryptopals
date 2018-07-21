describe Chal6 do
  let(:sample_path) { Pathname("#{__dir__}/data/6.txt") }
  let(:sample) { Base64.decode64(sample_path.read) }

  describe "#hamming_distance" do
    let(:a) { "this is a test" }
    let(:b) { "wokka wokka!!!" }

    it do
      expect(Chal6.new.hamming_distance(a,b)).to eq(37)
    end
  end

  describe "#repeated_edit_distance" do
    it do
      expect(Chal6.new.repeated_edit_distance(sample, 40)).to eq(3.18)
    end
  end

  describe "#guess_keysize" do
    it do
      expect(Chal6.new.guess_keysize(sample)).to eq(29)
    end
  end
end
