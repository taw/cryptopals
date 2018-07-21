class Chal11
  def random_key
    (0..15).map{ rand(256) }.pack("C*")
  end

  def random_padding
    rand(5..10).times.map{ rand(256) }.pack("C*")
  end

  def cbc_box
    key = random_key
    iv = random_key
    proc do |str|
      crypt = OpenSSL::Cipher.new("AES-128-CBC")
      crypt.encrypt
      crypt.key = key
      crypt.iv = iv
      crypt.update(random_padding + str + random_padding) + crypt.final
    end
  end

  def ecb_box
    key = random_key
    proc do |str|
      crypt = OpenSSL::Cipher.new("AES-128-ECB")
      crypt.encrypt
      crypt.key = key
      crypt.update(random_padding + str + random_padding) + crypt.final
    end
  end

  def random_box
    rand(2) == 0 ? cbc_box : ecb_box
  end

  def oracle(box)
    encrypted = box.call("A" * 100)
    slices = encrypted.chars.each_slice(16).map(&:join)
    if slices.size == slices.uniq.size
      :cbc
    else
      :ecb
    end
  end
end
