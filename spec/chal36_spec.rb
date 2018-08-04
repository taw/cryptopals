describe Chal36 do
  let(:network) { Chal36::Network.new }
  let(:server) { Chal36::Server.new("alice", "kittens") }
  let(:session) { network.call(client, server) }

  describe "Bad email" do
    let(:client) { Chal36::Client.new("bob", "kittens") }
    it do
      expect{ session }.to raise_error("Bad email")
    end
  end

  describe "Bad password" do
    let(:client) { Chal36::Client.new("alice", "puppies") }
    it do
      expect{ session }.to raise_error("Bad password")
    end
  end

  describe "Good email and password" do
    let(:client) { Chal36::Client.new("alice", "kittens") }
    it do
      expect(session).to eq("OK")
    end
  end
end
