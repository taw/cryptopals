class Chal29
  class Box
    def initialize(secret_size)
      @secret = Random.bytes(secret_size)
    end

    # Secure method, hack doesn't get access to the box
    def sign(msg)
      Digest::SHA1.hexdigest(@secret + msg)
    end

    def valid?(msg, mac)
      sign(msg) == mac
    end
  end

  # If we don't get secret_size, we'll need to try all combinations
  def hack(secret_size, msg, mac, final)
    sha1 = Chal28.new
    hash_words = mac.scan(/.{8}/).map{|u| u.to_i(16)}
    fake_secret = "A" * secret_size
    padded_orig_msg = sha1.pad_message(fake_secret + msg)
    glue_padding = padded_orig_msg.pack("N*")[(fake_secret.size + msg.size)..-1]
    padded_hack_msg = sha1.pad_message(fake_secret + msg + glue_padding + final)

    extra_data = padded_hack_msg[padded_orig_msg.size..-1]

    extra_data.each_slice(16) do |chunk|
      hash_words = sha1.sha1_reduce(chunk, hash_words)
    end

    hacked_mac = ("%08x"*5) % hash_words

    [msg + glue_padding + final, hacked_mac]
  end
end
