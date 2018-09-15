describe Chal56 do
  let(:chal) { Chal56.new }

  describe "bias tables generation" do
    let(:count) { 2**24 }
    let(:len) { 32 }

    it do
      fake_table = chal.generate_fake_bias_table(count).minmax
      tables = chal.generate_bias_tables(len, count)
      tablesmm = tables.map(&:minmax)

      # This one is enormous, but too early to be of much use
      # Usually these are about twice as large, but we don't want too flakey tests
      bias1 = tables[1].each_with_index.max
      expect(bias1[1]).to eq(0)
      expect(bias1[0]).to be > 64.0 * fake_table[1]

      bias15 = tables[15].each_with_index.max
      expect(bias15[1]).to eq(240)
      expect(bias15[0]).to be > 2.0 * fake_table[1]

      bias31 = tables[31].each_with_index.max
      expect(bias31[1]).to eq(224)
      expect(bias31[0]).to be > 1.5 * fake_table[1]
    end
  end

  describe "attack" do
    let(:full_cookie) { Base64.decode64("QkUgU1VSRSBUTyBEUklOSyBZT1VSIE9WQUxUSU5F") }
    let(:cookie) { full_cookie }
    let(:box) { chal.box(cookie) }
    let(:attacker) { Chal56::Attacker.new(box) }

    it "#cookie_len" do
      expect(attacker.cookie_len).to eq(cookie.size)
    end

    it "#best_bias_for" do
      expect(attacker.best_bias_for(0)).to eq(Chal56::Attacker::KNOWN_BIASES[0])
      expect(attacker.best_bias_for(1)).to eq(Chal56::Attacker::KNOWN_BIASES[0])
      expect(attacker.best_bias_for(2)).to eq(Chal56::Attacker::KNOWN_BIASES[1])
      expect(attacker.best_bias_for(15)).to eq(Chal56::Attacker::KNOWN_BIASES[1])
      expect(attacker.best_bias_for(16)).to eq(Chal56::Attacker::KNOWN_BIASES[2])
      expect{ attacker.best_bias_for(32) }.to raise_error "Unknown bias at position 32"
    end

    it "#attack_byte" do
      expect(attacker.attack_byte(0)[0]).to eq(cookie[0])
      expect(attacker.attack_byte(1)[0]).to eq(cookie[1])
    end

    describe "#attack" do
      # Full attack is very slow, so put only short version in specs
      let(:cookie) { full_cookie[0,3] }

      it do
        expect(attacker.attack).to eq(cookie)
      end
    end
  end
end
