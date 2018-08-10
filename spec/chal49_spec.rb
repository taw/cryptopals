describe Chal49 do
  let(:key) { AES.random_key }
  let(:server) { Chal49::Server.new(key) }
  let(:client1) { Chal49::WebClient.new(100, key) }
  let(:client2) { Chal49::WebClient.new(200, key) }
  let(:client3) { Chal49::WebClient.new(300, key) }

  # PART 1
  describe "Every cliet can sign only own requests" do
    let(:req1_good) { client1.generate_transfer_request(100, 200, 1000) }
    let(:req2_good) { client2.generate_transfer_request(200, 300, 2000) }
    let(:req1_bad) { client2.generate_transfer_request(100, 200, 3000) }
    let(:req2_bad) { client1.generate_transfer_request(200, 300, 4000) }

    it do
      expect(server.call(req1_good)).to eq(["OK", 100, 200, 1000])
      expect(server.call(req2_good)).to eq(["OK", 200, 300, 2000])
      expect{ req1_bad }.to raise_error("Can only sign messages from own account")
      expect{ req2_bad }.to raise_error("Can only sign messages from own account")
    end
  end

  # Target - 100
  # Attacker - 300/400s
  describe "Requests can be faked" do
    let(:req) { client3.generate_transfer_request(300, 400, 1_000_000) }
    let(:hacked) { Chal49.hack(req, 100, 300) }
    it do
      expect(server.call(hacked)).to eq(["OK", 100, 400, 1_000_000])
    end
  end

  # PART 2
  pending
end
