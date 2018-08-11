describe Chal52 do
  let(:f) { Chal52::F.new }
  let(:g) { Chal52::G.new }
  let(:fg) { Chal52::FG.new }

  describe "Hashes" do
    it do
      expect(f.hexdigest("Hello, world!")).to eq("0a30eb")
      expect(g.hexdigest("Hello, world!")).to eq("82f869da")
      expect(fg.hexdigest("Hello, world!")).to eq("0a30eb" + "82f869da")
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
      state = f.initial_state
      collisions = [""]
      4.times do
        state, collisions = f.extend_block_collision(state, collisions)
      end
      hashes = collisions.map{|msg| f.hexdigest(msg) }
      expect(collisions.size).to eq(16)
      expect(collisions.uniq.size).to eq(16)
      expect(hashes.uniq.size).to eq(1)
    end
  end

  describe "FG#find_collision" do
    it do
      m1, m2 = fg.find_collision
      expect(m1).to_not eq(m2)
      expect(fg.hexdigest(m1)).to eq(fg.hexdigest(m2))
    end
  end
end
