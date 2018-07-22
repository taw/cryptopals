describe Chal21 do
  # Using some ruby private methods to verify that we do the same thing

  describe "initialization" do
    let(:rng) { Chal21.new.tap{|rng| rng.seed(seed)} }
    let(:state) { rng.state }
    let(:rng_ruby) { Random.new(seed) }
    let(:state_ruby) { rng_ruby.send(:state).to_s(16).scan(/.{8}/).map{|u| u.to_i(16)}.reverse }

    describe "with 0" do
      let(:seed) { 0 }
      it do
        expect(state).to eq(state_ruby)
      end
    end

    describe "with time" do
      let(:seed) { Time.now.to_i }
      it do
        expect(state).to eq(state_ruby)
      end
    end
  end
end
