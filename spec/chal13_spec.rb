describe Chal13 do
  let(:chal) { Chal13.new }

  describe "#parse_query" do
    it do
      expect(chal.parse_query("email=foo@bar.com&uid=10&role=user")).to eq({
        "email" => "foo@bar.com",
        "uid" => "10",
        "role" => "user"
      })
    end
  end

  describe "#build_query_string" do
    it "normal use" do
      expect(chal.build_query_string({
        "email" => "foo@bar.com",
        "uid" => 10,
        "role" => "user"
      })).to eq("email=foo@bar.com&uid=10&role=user")
    end

    it "special charactes" do
      expect(chal.build_query_string({
        "email" => "foo@bar.com&admin=true",
        "uid" => 10,
        "role" => "user"
      })).to eq("email=foo@bar.comadmintrue&uid=10&role=user")
    end
  end

  describe "#profile_for" do
    it "normal use" do
      expect(chal.profile_for("foo@bar.com")).to eq("email=foo@bar.com&uid=10&role=user")
    end

    it "special characters" do
      expect(chal.profile_for("foo@bar.com&admin=true")).to eq("email=foo@bar.comadmintrue&uid=10&role=user")
    end
  end

  pending
end
