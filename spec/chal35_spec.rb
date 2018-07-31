describe Chal35 do
  let(:alice) { Chal35::Client.new }
  let(:bob) { Chal35::Server.new }
  # Private stuff, just for test access
  let(:alice_key) { alice.send(:key) }
  let(:bob_key) { bob.send(:key) }
  let(:alice_msg) { alice.send(:msg) }
  let(:alice_received_msg) { alice.send(:received_msg) }
  let(:bob_received_msg) { bob.send(:received_msg) }

  describe Chal35::Network do
    let(:network) { Chal34::Network.new }
    it do
      network.call(alice, bob)
      expect(alice_key).to eq(bob_key)
      expect(alice_msg).to eq(bob_received_msg)
      expect(alice_received_msg).to eq(bob_received_msg)
    end
  end

  describe Chal35::GInjectionNetwork1 do
    let(:network) { Chal35::GInjectionNetwork1.new }
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

  describe Chal35::GInjectionNetworkP do
    let(:network) { Chal35::GInjectionNetworkP.new }
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

  describe Chal35::GInjectionNetworkPminus1 do
    let(:network) { Chal35::GInjectionNetworkPminus1.new }

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
