describe Chal51 do
  describe "Crypto Boxes" do
    let(:session_id) { Base64.strict_encode64("All your base are belong to us!!") }
    let(:box) { described_class.new(session_id) }
    let(:content) { "Hello, world!" }
    let(:encoded) { box.encode(content) }
    let(:decoded) { box.decode(encoded) }

    describe Chal51::BoxCTR do
      it do
        expect(encoded.size).to eq(153)
        expect(decoded).to eq("POST / HTTP/1.1\r\nHost: hapless.com\r\nCookie: sessionid=QWxsIHlvdXIgYmFzZSBhcmUgYmVsb25nIHRvIHVzISE=\r\nContent-Length: 13\r\n\r\nHello, world!")
      end
    end

    describe Chal51::BoxCBC do
      it do
        expect(encoded.size).to eq(160)
        expect(decoded).to eq("POST / HTTP/1.1\r\nHost: hapless.com\r\nCookie: sessionid=QWxsIHlvdXIgYmFzZSBhcmUgYmVsb25nIHRvIHVzISE=\r\nContent-Length: 13\r\n\r\nHello, world!")
      end
    end
  end

  # actual hack
  describe "Hack" do
    let(:chal) { Chal51.new }
    let(:session_id) { Base64.strict_encode64(Random::DEFAULT.bytes(32)) }

    describe "Hacking CTR" do
      let(:box) { Chal51::BoxCTR.new(session_id) }

      it do
        expect(chal.hack(box)).to eq(session_id)
      end
    end

    describe "Hacking CBC" do
      let(:box) { Chal51::BoxCBC.new(session_id) }

      it do
        expect(chal.hack(box)).to eq(session_id)
      end
    end
  end
end
