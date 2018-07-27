describe Chal14 do
  let(:chal) { Chal14.new }

  describe "#message_size" do
    it do
      expect(chal.message_size(chal.box)).to eq(138)
    end
  end

  describe "#crack_message" do
    it do
      expect(chal.crack_message(chal.box)).to eq(
        "Rollin' in my 5.0\n"+
        "With my rag-top down so my hair can blow\n"+
        "The girlies on standby waving just to say hi\n"+
        "Did you stop? No, I just drove by\n"
      )
    end
  end
end
