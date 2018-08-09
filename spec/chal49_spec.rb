describe Chal49 do
  let(:keys) {
    {
      100 => AES.random_key,
      200 => AES.random_key,
      300 => AES.random_key,
    }
  }
  let(:server) { Chal49::Server.new(keys) }
  let(:client1) { Chal49::Client.new(100, keys[100]) }
  let(:client2) { Chal49::Client.new(200, keys[200]) }
  let(:client3) { Chal49::Client.new(300, keys[300]) }

  # PART 1
  describe "Every cliet can sign only own requests" do
    let(:req1_good) { client1.generate_transfer_request(100, 200, 1000) }
    let(:req2_good) { client2.generate_transfer_request(200, 300, 2000) }
    let(:req1_bad) { client2.generate_transfer_request(100, 200, 3000) }
    let(:req2_bad) { client1.generate_transfer_request(200, 300, 4000) }

    it do
      expect(server.call(req1_good)).to eq(["OK", 100, 200, 1000])
      expect(server.call(req2_good)).to eq(["OK", 200, 300, 2000])
      expect{ server.call(req1_bad) }.to raise_error("Invalid MAC")
      expect{ server.call(req2_bad) }.to raise_error("Invalid MAC")
    end
  end

  describe "Requests can be faked" do
    # ...
    pending
  end

  # PART 2
  pending
end
