class Chal7
  def decode(encrypted, key)
    AES.decrypt_ecb(encrypted, key)
  end
end
