describe Chal38 do
  let(:network) { Chal38::Network.new }
  let(:server) { Chal38::Server.new("alice", "kittens") }
  let(:session) { network.call(client, server) }

  describe "Bad email" do
    let(:client) { Chal38::Client.new("bob", "kittens") }
    it do
      expect{ session }.to raise_error("Bad email")
    end
  end

  describe "Bad password" do
    let(:client) { Chal38::Client.new("alice", "puppies") }
    it do
      expect{ session }.to raise_error("Bad password")
    end
  end

  describe "Good email and password" do
    let(:client) { Chal38::Client.new("alice", "kittens") }
    it do
      expect(session).to eq("OK")
    end
  end

  describe "MITM attack" do
    let(:server) { Chal38::FakeServer.new }
    let(:client) { Chal38::Client.new("alice", "aardvark") }
    it do
      expect(session).to eq("OK")
      # b, B, u, and salt
    end
  end
end
