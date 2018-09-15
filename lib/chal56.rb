class Chal56
  def encrypt_with_random_key(msg)
    cipher = OpenSSL::Cipher::RC4.new
    cipher.encrypt
    cipher.key = cipher.random_key
    # It's stream cipher so no need for update block
    cipher.update(msg)
  end

  def box(cookie)
    proc do |msg|
      encrypt_with_random_key(msg + cookie)
    end
  end

  # count multiples of 256 please
  def generate_bias_tables(len, count)
    avg_count = count / 256
    tables = len.times.map{ [-avg_count] * 256 }
    pt = "\x00".b * len
    count.times do
      ct = encrypt_with_random_key(pt)
      ctb = ct.bytes
      ctb.each_with_index do |b,i|
        tables[i][b] += 1
      end
    end
    tables
  end

  # unbiased table (MT bias is nearly nonexistent)
  def generate_fake_bias_table(count)
    avg_count = count / 256
    table = [-avg_count] * 256
    count.times do
      b = rand(256)
      table[b] += 1
    end
    table
  end

  class Attacker
    KNOWN_BIASES = [
      [ 1,   0, 2**16],
      [15, 240, 2**24],
      [31, 224, 2**24],
    ]

    def initialize(box)
      @box = box
    end

    def cookie_len
      @cookie_len ||= @box[""].size
    end

    def best_bias_for(i)
      KNOWN_BIASES.find{|j,| j >= i} or raise "Unknown bias at position #{i}"
    end

    def attack_byte(target_ofs)
      bias_ofs, bias_value, count = best_bias_for(target_ofs)
      pad = "\x00".b * (bias_ofs - target_ofs)
      table = [0] * 256
      count.times do
        ctb = @box[pad][bias_ofs].ord
        table[ctb] += 1
      end
      # v1 is actual answer, rest just for debugging
      (most_common_freq, most_common_value), (most_common_freq2, most_common_value2) = table.each_with_index.sort.reverse
      v1 = (bias_value ^ most_common_value).chr
      v2 = (bias_value ^ most_common_value2).chr
      r = most_common_freq.to_f / most_common_freq2
      [v1, v2, r]
    end

    def attack
      cookie_len.times.map do |target_ofs|
        b1, b2, ratio = attack_byte(target_ofs)
        # puts "Found: #{b1.inspect} #{b2.inspect} #{ratio} - at #{target_ofs}"
        b1
      end.join
    end
  end
end
