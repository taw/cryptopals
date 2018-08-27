describe Chal63 do
  let(:chal) { Chal63.new }

  let(:key) { Random::DEFAULT.bytes(16) }
  let(:iv) { Random::DEFAULT.bytes(12) }

  let(:pt1) { "All your base are belong to us!" }
  let(:aad1) { "Version 1" }

  let(:pt2) { "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." }
  let(:aad2) { "Version 2" }

  let(:msg1) { GCM.encrypt(key, iv, aad1, pt1) }
  let(:msg2) { GCM.encrypt(key, iv, aad2, pt2) }
  let(:ct1) { msg1[1] }
  let(:ct2) { msg2[1] }
  let(:tag1) { msg1[2] }
  let(:tag2) { msg2[2] }

  let(:h) { GCM.calculate_h(key) }
  let(:mask) { GCM.iv_block(key, iv) }

  # It can only be verified by recipient, so not part of the hack, just sanity check
  it "is valid" do
    _, dpt1, dtag1 = GCM.decrypt(key, iv, aad1, ct1)
    expect(dtag1).to eq(tag1)
    expect(dpt1).to eq(pt1)

    _, dpt2, dtag2 = GCM.decrypt(key, iv, aad2, ct2)
    expect(dtag2).to eq(tag2)
    expect(dpt2).to eq(pt2)
  end

  it "GCM.pow" do
    expect(GCM.pow(h, 3)).to eq( GCM.mul(GCM.mul(h, h), h) )
  end

  describe "msg_blocks" do
    it "trivial message" do
      aad, ct, tag = GCM.encrypt(key, iv, "", "x")
      blocks = chal.msg_blocks(aad, ct)
      expect(blocks.size).to eq(2)
      atag = GCM.mul(GCM.mul(h, h), blocks[1]) ^  GCM.mul(h, blocks[0]) ^ mask
      expect(atag).to eq(tag)
    end

    it "msg1" do
      blocks = chal.msg_blocks(aad1, ct1)
      atag1 = chal.eval_poly(blocks, h) ^ mask
      expect(atag1).to eq(tag1)
    end

    it "msg2" do
      blocks = chal.msg_blocks(aad2, ct2)
      atag2 = chal.eval_poly(blocks, h) ^ mask
      expect(atag2).to eq(tag2)
    end
  end

  it "extract_poly" do
    poly = chal.extract_poly(msg1, msg2)
    expect(chal.eval_poly(poly, h)).to eq(tag1 ^ tag2)
  end

  # Actual hack
  pending
end
