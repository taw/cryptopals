describe Chal34 do
  let(:alice) { Chal34::Client.new }
  let(:bob) { Chal34::Server.new }
  # Private stuff, just for test access
  let(:alice_key) { alice.send(:key) }
  let(:bob_key) { bob.send(:key) }
  let(:alice_msg) { alice.send(:msg) }
  let(:alice_received_msg) { alice.send(:received_msg) }
  let(:bob_received_msg) { bob.send(:received_msg) }

  describe Chal34::Network do
    let(:network) { Chal34::Network.new }
    it do
      network.call(alice, bob)
      expect(alice_key).to eq(bob_key)
      expect(alice_msg).to eq(bob_received_msg)
      expect(alice_received_msg).to eq(bob_received_msg)
    end
  end

  describe Chal34::TraditionalMitmNetwork do
    let(:network) { Chal34::TraditionalMitmNetwork.new }
    it do
      network.call(alice, bob)
      expect(alice_key).to eq(network.client_key)
      expect(bob_key).to eq(network.server_key)
      expect(alice_key).to_not eq(bob_key)
      expect(alice_msg).to eq(network.received_msg1)
      expect(network.received_msg1).to eq(bob_received_msg)
      expect(bob_received_msg).to eq(network.received_msg2)
      expect(network.received_msg2).to eq(alice_received_msg)
    end
  end

  describe Chal34::ParameterInjectionMitmNetwork do
    let(:network) { Chal34::ParameterInjectionMitmNetwork.new }
    it do
      network.call(alice, bob)
      expect(alice_key).to eq(network.key)
      expect(bob_key).to eq(network.key)
      expect(alice_key).to eq(bob_key)
      expect(alice_msg).to eq(network.received_msg1)
      expect(network.received_msg1).to eq(bob_received_msg)
      expect(bob_received_msg).to eq(network.received_msg2)
      expect(network.received_msg2).to eq(alice_received_msg)
    end
  end
end
