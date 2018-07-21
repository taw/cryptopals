describe Chal6 do
  describe "#hamming_distance" do
    let(:a) { "this is a test" }
    let(:b) { "wokka wokka!!!" }

    it do
      expect(Chal6.new.hamming_distance(a,b)).to eq(37)
    end
  end

  describe "#repeated_edit_distance" do

    it do

    end
  end

  describe "#guess_keysize" do

  end
end
