describe Chal63 do
  let(:chal) { Chal63.new }

  let(:key) { Random.bytes(16) }
  let(:iv) { Random.bytes(12) }

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

  let(:h) { GCMField.new GCM.calculate_h(key) }
  let(:mask) { GCMField.new GCM.iv_block(key, iv) }

  # It can only be verified by recipient, so not part of the hack, just sanity check
  it "is valid" do
    _, dpt1, dtag1 = GCM.decrypt(key, iv, aad1, ct1)
    expect(dtag1).to eq(tag1)
    expect(dpt1).to eq(pt1)

    _, dpt2, dtag2 = GCM.decrypt(key, iv, aad2, ct2)
    expect(dtag2).to eq(tag2)
    expect(dpt2).to eq(pt2)
  end

  it "GCMField#**" do
    expect(h**3).to eq(h*h*h)
  end

  describe "msg_blocks" do
    it "trivial message" do
      aad, ct, tag = GCM.encrypt(key, iv, "", "x")
      blocks = chal.msg_blocks(aad, ct).a
      expect(blocks.size).to eq(3)
      atag = h*h*blocks[2] + h*blocks[1] + blocks[0] + mask
      expect(atag.to_i).to eq(tag)
    end

    it "msg1" do
      blocks = chal.msg_blocks(aad1, ct1)
      atag1 = blocks.eval(h) + mask
      expect(atag1.to_i).to eq(tag1)
    end

    it "msg2" do
      blocks = chal.msg_blocks(aad2, ct2)
      atag2 = blocks.eval(h) + mask
      expect(atag2.to_i).to eq(tag2)
    end
  end

  it "extract_poly" do
    poly = chal.extract_poly(msg1, msg2)
    expect(poly.eval(h)).to be_zero
  end

  it "GCMField#to_monic" do
    poly = chal.extract_poly(msg1, msg2)
    monic_poly = poly.to_monic
    expect(monic_poly.a.last).to be_one
    expect(monic_poly.eval(h)).to be_zero
  end

  it "candidate_keys" do
    keys = chal.candidate_keys(msg1, msg2)
    expect(keys).to include([h, mask])
  end

  # From candidate_keys
  it "create_fake_message" do
    ptxor = "PWNED!!!".xor("All your") + "\x00".b*23
    msg3 = chal.create_fake_message(h, mask, "Version 3", ct1, ptxor)

    aad3, ct3, tag3 = msg3
    # This part is happening on victim's machine
    decoded = GCM.decrypt(key, iv, aad3, ct3)
    expect(decoded).to eq([
      "Version 3",
      "PWNED!!! base are belong to us!",
      tag3,
    ])
  end
end
