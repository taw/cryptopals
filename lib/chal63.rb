class Chal63
  def extract_poly(msg1, msg2)
    aad1, ct1, tag1 = msg1
    aad2, ct2, tag2 = msg2

    m1 = msg_blocks(aad1, ct1)
    m2 = msg_blocks(aad2, ct2)

    dtag = tag1 ^ tag2

    max_size = [m1.size, m2.size].max
    max_size.times.map{|i| m1.fetch(i,0) ^ m2.fetch(i,0) }
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
    blocks.reverse
  end

  # Doing it stupid way here
  def eval_poly(poly, h)
    poly.map.with_index{|b,i| GCM.mul(GCM.pow(h, i+1), b) }.inject{|a,b| a^b}
  end
end
