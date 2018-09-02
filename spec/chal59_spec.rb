describe Chal59 do
  let(:prime) { 233970423115425145524320034830162017933 }
  let(:group) { WeierstrassCurve.new(prime, -95051, 11279326) }
  let(:base_point) { [182, 85518893674295321206118380980485522083] }
  let(:order) { 29246302889428143187362802287225875743 }
  it do
    expect(group.valid?(base_point))
    expect(group.multiply(base_point, order)).to eq :infinity
  end

  describe "handshake" do
    let(:alice) { Chal59::Client.new(group, base_point, order) }
    let(:bob) { Chal59::Client.new(group, base_point, order) }
    let(:alice_public) { alice.public }
    let(:bob_public) { bob.public }
    it do
      alice.receive(bob_public)
      bob.receive(alice_public)
      expect(alice.key).to eq(bob.key)
    end
  end

  describe "hack" do
    let(:attacker) { Chal59::Attacker.new }
    let(:group1) { WeierstrassCurve.new(prime, -95051, 210) }
    let(:group2) { WeierstrassCurve.new(prime, -95051, 504) }
    let(:group3) { WeierstrassCurve.new(prime, -95051, 727) }
    let(:order1) { 233970423115425145550826547352470124412 }
    let(:order2) { 233970423115425145544350131142039591210 }
    let(:order3) { 233970423115425145545378039958152057148 }
    let(:factors1) { [2, 2, 3, 11, 23, 31, 89, 4999, 28411, 45361, 109138087, 39726369581] }
    let(:factors2) { [2, 5, 7, 11, 61, 12157, 34693, 11810604523200031240395593] }
    let(:factors3) { [2, 2, 7, 23, 37, 67, 607, 1979, 13327, 13799, 663413139201923717] }
    let(:attack_list1) { [11, 23, 31, 89, 4999] }
    let(:attack_list2) { [7, 61, 12157, 34693] }
    let(:attack_list3) { [37, 67, 607, 1979, 13327, 13799] }

    it "factorization" do
      expect(order1).to eq factors1.inject{|u,v| u*v}
      expect(order2).to eq factors2.inject{|u,v| u*v}
      expect(order3).to eq factors3.inject{|u,v| u*v}
    end

    it "attack list" do
      expect(attack_list1 - factors1).to be_empty
      expect(attack_list2 - factors2).to be_empty
      expect(attack_list3 - factors3).to be_empty
      expect([*attack_list1, *attack_list2, *attack_list3].inject{|u,v| u*v}).to be > order
    end

    describe "attack" do
      let(:client) { Chal59::Client.new(group, base_point, order) }
      let(:attacker) {
        Chal59::Attacker.new(
          client,
          group1, order1, attack_list1,
          group2, order2, attack_list2,
          group3, order3, attack_list3,
        )
      }
      it do
        expect(attacker.secret).to eq(client.send(:secret))
      end
    end
  end
end
