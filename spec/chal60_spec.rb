describe Chal60 do
  let(:prime) { 233970423115425145524320034830162017933 }
  let(:montgomery_curve) { MontgomeryCurve.new(prime, 534, 1) }
  let(:base_point) { 4 }
  let(:base_point_order) { 29246302889428143187362802287225875743 }
  let(:order) { 233970423115425145498902418297807005944 }

  let(:twist_order) { 2 * prime + 2 - order }
  let(:twist_factors) { [ 2, 2, 11, 107, 197, 1621, 105143, 405373, 2323367, 1571528514013 ] }

  describe "handshake" do
    let(:alice) { Chal60::Client.new(montgomery_curve, base_point, base_point_order) }
    let(:bob) { Chal60::Client.new(montgomery_curve, base_point, base_point_order) }
    let(:alice_public) { alice.public }
    let(:bob_public) { bob.public }
    it do
      alice.receive(bob_public)
      bob.receive(alice_public)
      expect(alice.key).to eq(bob.key)
    end
  end

  # All the hacking
  describe "attack" do
    let(:client) { Chal60::Client.new(montgomery_curve, base_point, order) }
    # let(:attackable_twist_factors) { [11, 107, 197, 1621, 105143, 405373, 2323367] }
    let(:attackable_twist_factors) { [11, 107, 197, 1621, 105143, 405373, 2323367, 1571528514013] }
    let(:attackable_product) { attackable_twist_factors.reduce{ |u,v| u*v } }
    let(:secret) { client.send(:secret) }
    let(:attacker) {
      Chal60::Attacker.new(
        client,
        montgomery_curve,
        twist_order,
        attackable_twist_factors,
      )
    }
    let(:expected_first_pass) { attackable_twist_factors.map{ |k| [k, [secret % k, -secret % k].uniq.sort] } }
    let(:expected_second_pass) {
      [secret % attackable_product, -secret % attackable_product].sort.uniq
    }
    let(:secret_found) { attacker.secret }
    it do
      expect(attacker.first_pass).to eq(expected_first_pass)
      # attacker.instance_variable_set(:@first_pass, expected_first_pass) # Bypass for performance sake
      # expect(attacker.second_pass).to eq(expected_second_pass)
      expect(attacker.second_pass).to include(expected_second_pass[0])
      expect(attacker.second_pass).to include(expected_second_pass[1])
      expect([secret, order-secret]).to include(secret_found)
    end
  end
end
