class Chal42
  def hack(public_key, msg)
    hash = Digest::SHA1.hexdigest(msg)
    # padding size doesn't really matter
    prefix = "0001" + "ff" * 1 + "00" + hash
    min = (prefix + "0" * (public_key.signature_size*2 - prefix.size)).to_i(16)
    # 1 to n^(1/3) actually
    (1..public_key.n/2).bsearch{|x|
      x ** 3 > min
    }
  end
end
