describe Chal6 do
  let(:chal) { Chal6.new }
  let(:sample_path) { Pathname("#{__dir__}/data/6.txt") }
  let(:sample) { Base64.decode64(sample_path.read) }

  describe "#hamming_distance" do
    let(:a) { "this is a test" }
    let(:b) { "wokka wokka!!!" }

    it do
      expect(chal.hamming_distance(a,b)).to eq(37)
    end
  end

  describe "#repeated_edit_distance" do
    it do
      expect(chal.repeated_edit_distance(sample, 40)).to eq(3.18)
    end
  end

  describe "#guess_keysize" do
    it do
      expect(chal.guess_keysize(sample)).to eq(29)
    end
  end

  describe "#call" do
    it do
      key, decrypted = chal.call(sample)
      expect(key).to eq("Terminator X: Bring the noise")
      expect(decrypted).to match(/Play that funky music/)
    end
  end
end
