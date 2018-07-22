describe Chal21 do
  # Using some ruby private methods to verify that we do the same thing
  let(:rng) { Chal21.new.tap{|rng| rng.seed(seed)} }
  let(:rng_ruby) { Random.new(seed) }

  describe "initialization" do
    let(:state) { rng.state }
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

  describe "random numbers" do
    let(:random_numbers) { 2000.times.map { rng.extract_number } }
    let(:random_numbers_ruby) { 2000.times.map { rng_ruby.bytes(4).unpack("V")[0] } }

    describe "with 0" do
      let(:seed) { 0 }
      it do
        expect(random_numbers).to eq(random_numbers_ruby)
      end
    end

    describe "with time" do
      let(:seed) { Time.now.to_i }
      it do
        expect(random_numbers).to eq(random_numbers_ruby)
      end
    end
  end
end
