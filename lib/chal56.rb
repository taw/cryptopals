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
    def initialize(box)
      @box = box
    end

    def cookie_len
      @cookie_len ||= @box[""].size
    end

    def attack(box)
      cookie_len
    end
  end
end
