describe Chal23 do
  let(:chal) { Chal23.new }

  # This is important part of analysis
  describe "temper_by_equations" do
    it do
      100.times do
        y = rand(2**32)
        expect(chal.temper_by_equations(y)).to eq(chal.temper(y))
      end
    end
  end

  # It's possible to invert the GF(2) 32x32 matrix of #temper function
  # Or we could just skip all that hard work and use Z3 to do it for us ;-)
  describe "untemper" do
    it do
      100.times do
        y = rand(2**32)
        x = chal.temper(y)
        z = chal.untemper(x)
        expect(chal.temper(z)).to eq(x)
        expect(z).to eq(y)
      end
    end
  end

  describe "clone" do
    let(:seed) { rand(2**32) }
    let(:rng) {  Chal21.new.tap{|rng| rng.seed(seed) } }

    it do
      cloned = chal.clone(rng)
      expect(cloned.state).to eq(rng.state)
    end
  end
end
