class Chal50
  def cbc_mac(msg, key, iv)
    AES.encrypt_cbc(msg, key, iv)[-16..-1].to_hex
  end

  def hack(injected, key, iv, target_hash)
    decrypted_target_hash = AES.decrypt_block(target_hash.from_hex, key)

    # It's easier to work with multiples of full block
    msg = injected + " " * ((-injected.size-2) % 16) + "//"
    ct = iv
    msg.byteslices(16).each do |slice|
      pt = slice.xor(ct)
      ct = AES.encrypt_block(pt, key)
    end

    # I'm not sure what's the best way to deal with padding
    (0..2**32).each do |i|
      trash_block = "%16d" % i
      ct2 = AES.encrypt_block(trash_block.xor(ct), key)

      final_block = ct2.xor(decrypted_target_hash)
      next if final_block[-1] != "\x01".b
      final_block = final_block[0..-2]
      next if final_block.include?("\n".b)
      # This will still fail to be valid UTF-8
      # Naive attack ensuring ASCII only and valid padding takes 2^15 * 2^8 tries
      # There's probably some clever way to speed it up, probably usisng multiple blocks
      return msg + trash_block + final_block
    end
    raise "Attack failed"
  end
end
