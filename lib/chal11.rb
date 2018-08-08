class Chal11
  def random_padding
    Random::DEFAULT.bytes(rand(5..10))
  end

  def cbc_box
    key = AES.random_key
    iv = AES.random_key
    proc do |str|
      AES.encrypt_cbc(random_padding + str + random_padding, key, iv)
    end
  end

  def ecb_box
    key = AES.random_key
    proc do |str|
      AES.encrypt_ecb(random_padding + str + random_padding, key)
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
