describe Chal52 do
  let(:f) { Chal52::F.new }
  let(:g) { Chal52::G.new }
  let(:fg) { Chal52::FG.new }

  describe "Hashes" do
    it do
      expect(f.hexdigest("Hello, world!")).to eq("53fe")
      expect(g.hexdigest("Hello, world!")).to eq("111507")
      expect(fg.hexdigest("Hello, world!")).to eq("53fe" + "111507")
    end
  end

  describe "#find_block_collision" do
    it do
      c1, c2, h = f.find_block_collision(f.initial_state)
      expect(c1).to_not eq(c2)
      expect(f.hexdigest(c1)).to eq(f.hexdigest(c2))
    end
  end

  describe "#extend_block_collision" do
    it do
      state_and_collisions = [f.initial_state]
      4.times do
        state_and_collisions = f.extend_block_collision(*state_and_collisions)
      end
      all_msgs = state_and_collisions[1..-1].reduce([""]){|msgs,(a,b)| msgs.flat_map{|msg| [msg+a, msg+b] }  }
      hashes = all_msgs.map{|msg| f.hexdigest(msg) }
      expect(all_msgs.size).to eq(16)
      expect(all_msgs.uniq.size).to eq(16)
      expect(hashes.uniq.size).to eq(1)
    end
  end

  describe "hack" do
    pending
  end
end
