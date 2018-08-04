describe Chal37 do
  let(:network) { Chal37::Network.new }
  let(:server) { Chal37::Server.new("alice", "kittens") }
  let(:session) { network.call(client, server) }

  describe "Bad password, a=0" do
    let(:client) { Chal37::Client_0.new("alice", "puppies") }
    it do
      expect(session).to eq("OK")
    end
  end

  describe "Bad password, a=n" do
    let(:client) { Chal37::Client_N.new("alice", "puppies") }
    it do
      expect(session).to eq("OK")
    end
  end

  describe "Bad password, a=2*n" do
    let(:client) { Chal37::Client_2N.new("alice", "puppies") }
    it do
      expect(session).to eq("OK")
    end
  end
end
