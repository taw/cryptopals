describe Chal59 do
  let(:group) {
    ECC.new(
      233970423115425145524320034830162017933,
      -95051,
      11279326,
    )
  }
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
end
