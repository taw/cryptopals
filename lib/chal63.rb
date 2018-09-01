class Chal63
  def extract_poly(msg1, msg2)
    zero = GCMField.zero
    aad1, ct1, tag1 = msg1
    aad2, ct2, tag2 = msg2

    m1 = msg_blocks(aad1, ct1)
    m2 = msg_blocks(aad2, ct2)
    dtag = GCMField.new(tag1) + GCMField.new(tag2)
    m1 + m2 + dtag
  end

  def msg_blocks(aad, ct)
    blocks = []
    GCM.each_aad_block(aad) do |block|
      blocks << block.to_hex.to_i(16)
    end

    GCM.each_message_block(ct) do |block, j|
      ctval = block + "\x00".b * (16 - block.size)
      blocks << ctval.to_hex.to_i(16)
    end

    blocks << GCM.final_block(aad, ct)
    GCMPoly.new [GCMField.zero, *blocks.reverse.map{|i| GCMField.new(i) }]
  end

  # It's pretty slow implementation
  def candidate_keys(msg1, msg2)
    aad1, ct1, tag1 = msg1
    extract_poly(msg1, msg2)
      .roots
      .map{|h| [h, msg_blocks(aad1, ct1).eval(h) + GCMField.new(tag1)] }
  end

  # It's CTR, so we can use any CTR attack to deal with encryption
  # This is simplest version of the attack:
  # * we can completely replace aad
  # * in CTR ptxor = ctxor
  def create_fake_message(h, mask, aad, ct, ptxor)
    ctx = ct.xor(ptxor)
    tag = msg_blocks(aad, ctx).eval(h) + mask
    [aad, ctx, tag.to_i]
  end
end
