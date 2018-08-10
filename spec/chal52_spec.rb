describe Chal52 do
  describe "Hashes" do
    it do
      expect(Chal52::F.new.hexdigest("Hello, world!")).to eq("b99f9769")
      expect(Chal52::G.new.hexdigest("Hello, world!")).to eq("e1df55cda0cc")
      expect(Chal52::FG.new.hexdigest("Hello, world!")).to eq("b99f9769" + "e1df55cda0cc")
    end
  end
end
