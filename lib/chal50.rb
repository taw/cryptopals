class Chal50
  def cbc_mac(msg, key, iv)
    AES.encrypt_cbc(msg, key, iv)[-16..-1].to_hex
  end
end
