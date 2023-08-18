describe Chal64 do
  it "gcm_mul_matrix" do
    a = rand(0...2**128)
    b = rand(0...2**128)
    ma = Chal64.gcm_mul_matrix(a)
    expect(ma*b).to eq((GCMField.new(a) * GCMField.new(b)).value)
  end

  it "gcm_square_matrix" do
    ms = Chal64.gcm_square_matrix
    a = rand(0...2**128)
    expect(ms*a).to eq((GCMField.new(a) * GCMField.new(a)).value)
  end

  describe "diff_matrix" do
    let(:key) { Random.bytes(16) }
    let(:iv) { Random.bytes(12) }
    let(:h) { GCM.calculate_h(key) }
    let(:aad) { "" }
    let(:pt2) { Chal64.apply_diff(pt1, diffs) }
    let(:diff_matrix) { Chal64.diff_matrix(diffs) }
    let(:tag1) { GCM.encrypt(key, iv, aad, pt1)[2] }
    let(:tag2) { GCM.encrypt(key, iv, aad, pt2)[2] }
    let(:dtag) { tag1 ^ tag2 }

    describe "1 diff" do
      let(:pt1) { Random.bytes(16) }
      let(:diffs) { [Random.bytes(16)] }
      let(:h2) { GCM.mul(h, h) }
      let(:h2_pt1_c2) { GCM.mul(h2, pt1.to_hex.to_i(16)) }
      let(:h2_pt2_c2) { GCM.mul(h2, pt2.to_hex.to_i(16)) }

      it do
        expect(h2_pt1_c2 ^ h2_pt2_c2).to eq(dtag)
        expect(diff_matrix * h).to eq(dtag)
      end
    end

    describe "2 diffs" do
      let(:pt1) { Random.bytes(16*3) }
      let(:diffs) { 2.times.map{ Random.bytes(16) } }
      let(:h2) { GCM.mul(h, h) }
      let(:h4) { GCM.mul(h2, h2) }
      let(:h2_pt1_c2) { GCM.mul(h2, pt1[32,16].to_hex.to_i(16)) }
      let(:h4_pt1_c4) { GCM.mul(h4, pt1[ 0,16].to_hex.to_i(16)) }
      let(:h2_pt2_c2) { GCM.mul(h2, pt2[32,16].to_hex.to_i(16)) }
      let(:h4_pt2_c4) { GCM.mul(h4, pt2[ 0,16].to_hex.to_i(16)) }

      it do
        expect(h2_pt1_c2 ^ h2_pt2_c2 ^ h4_pt1_c4 ^ h4_pt2_c4).to eq(dtag)
        expect(diff_matrix * h).to eq(dtag)
      end
    end

    describe "8 diffs" do
      let(:pt1) { Random.bytes(16*256) }
      let(:diffs) { 8.times.map { Random.bytes(16) } }

      it do
        expect(diff_matrix * h).to eq(dtag)
      end
    end
  end

  pending
end
