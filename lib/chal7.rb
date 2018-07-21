class Chal7
  def decode(encrypted, key)
    decipher = OpenSSL::Cipher.new("AES-128-ECB")
    decipher.decrypt
    decipher.key = key
    plain = decipher.update(encrypted) + decipher.final
  end
end
