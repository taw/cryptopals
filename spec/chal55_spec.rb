describe Chal55 do
  describe "Examples from Wang paper" do
    let(:v1a) { %W[
      4d7a9c83 56cb927a b9d5a578 57a7a5ee de748a3c dcc366b3 b683a020 3b2a5d9f
      c69d71b3 f9e99198 d79f805e a63bb2e8 45dd8e31 97e31fe5 2794bf08 b9e8c3e9
    ].map{ |x| x.to_i(16) } }
    let(:v1b) { %W[
      4d7a9c83 d6cb927a 29d5a578 57a7a5ee de748a3c dcc366b3 b683a020 3b2a5d9f
      c69d71b3 f9e99198 d79f805e a63bb2e8 45dc8e31 97e31fe5 2794bf08 b9e8c3e9
    ].map{ |x| x.to_i(16) } }
    let(:v2a) { %W[
      4d7a9c83 56cb927a b9d5a578 57a7a5ee de748a3c dcc366b3 b683a020 3b2a5d9f
      c69d71b3 f9e99198 d79f805e a63bb2e8 45dd8e31 97e31fe5 f713c240 a7b8cf69
    ].map{ |x| x.to_i(16) } }
    let(:v2b) { %W[
      4d7a9c83 d6cb927a 29d5a578 57a7a5ee de748a3c dcc366b3 b683a020 3b2a5d9f
      c69d71b3 f9e99198 d79f805e a63bb2e8 45dc8e31 97e31fe5 f713c240 a7b8cf69
    ].map{ |x| x.to_i(16) } }

    let(:m1a) { v1a.pack("V*") }
    let(:m1b) { v1b.pack("V*") }
    let(:m2a) { v2a.pack("V*") }
    let(:m2b) { v2b.pack("V*") }

    describe "Full MD4" do
      let(:h1a) { OpenSSL::Digest::MD4.hexdigest(m1a) }
      let(:h1b) { OpenSSL::Digest::MD4.hexdigest(m1b) }
      let(:h2a) { OpenSSL::Digest::MD4.hexdigest(m2a) }
      let(:h2b) { OpenSSL::Digest::MD4.hexdigest(m2b) }

      it do
        expect(m1a).to_not eq(m1b)
        expect(h1a).to eq(h1b)
        expect(m2a).to_not eq(m2b)
        expect(h2a).to eq(h2b)
      end
    end

    describe "MD4 reduce" do
      let(:initial_state) { Chal55::IntrospectiveMD4.initial_state }

      let(:h1a) { Chal55::IntrospectiveMD4.reduce(initial_state, m1a)[0] }
      let(:h1b) { Chal55::IntrospectiveMD4.reduce(initial_state, m1b)[0] }
      let(:h2a) { Chal55::IntrospectiveMD4.reduce(initial_state, m2a)[0] }
      let(:h2b) { Chal55::IntrospectiveMD4.reduce(initial_state, m2b)[0] }

      it do
        expect(h1a).to eq(h1b)
        expect(h2a).to eq(h2b)
      end
    end

    describe "Differences" do
      let(:m1diff) { Chal55::IntrospectiveMD4.diff(m1a, m1b) }
      let(:m2diff) { Chal55::IntrospectiveMD4.diff(m2a, m2b) }

      it do
        # Diffs don't seem quite what the paper shows due to mod 2**32 arithmetic
        expect(m1diff[:message_diffs]).to eq([0, 2**31, 2**31 - 2**28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2**32 - 2**16, 0, 0, 0])
        expect(m2diff[:message_diffs]).to eq([0, 2**31, 2**31 - 2**28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2**32 - 2**16, 0, 0, 0])
        expect(m1diff[:intermediate_diffs]).to eq(m2diff[:intermediate_diffs])
      end
    end

    it "verify_round1_conditions" do
      expect(Chal55.verify_round1_conditions(m1a)).to eq true
      expect(Chal55.verify_round1_conditions(m1b)).to eq false
      expect(Chal55.verify_round1_conditions(m2a)).to eq true
      expect(Chal55.verify_round1_conditions(m2b)).to eq false
    end
  end

  describe "#generate_candidate_pair" do
    it do
      m1, m2 = Chal55.generate_candidate_pair
      diff = Chal55::IntrospectiveMD4.diff(m1, m2)
      expect(diff[:message_diffs]).to eq([0, 2**31, 2**31 - 2**28, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2**32 - 2**16, 0, 0, 0])
      expect(Chal55.verify_round1_conditions(m1)).to eq true
      expect(Chal55.verify_round1_conditions(m2)).to eq false

      # t0 = Time.now
      # 20_000.times {
      #   Chal55.generate_candidate_pair
      # }
      # dt = Time.now-t0
      # p [:took, dt]
    end
  end

  pending
end
