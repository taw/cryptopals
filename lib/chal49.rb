class Chal49
  class Server
    def initialize(key)
      @key = key
    end

    def call(request)
      message, iv, mac = parse_request(request)
      from_id, to_id, amount = parse_message(message)
      raise "Invalid MAC" unless cbc_mac(message, iv) == mac
      # Everythig is good, so execute!
      ["OK", from_id, to_id, amount]
    end

    private

    def key_for(account)
      @keys[account] or raise "Account #{account} not found"
    end

    def parse_message(message)
      raise "Invalid message: #{message.inspect}" unless message =~ /\Afrom=(\d+)&to=(\d+)&amount=(\d+)\z/
      [$1.to_i, $2.to_i, $3.to_i]
    end

    def parse_request(request)
      # Require at least one byte
      raise "Request too short" unless request.size >= 33
      mac = request[-16..-1]
      iv = request[-32..-17]
      message = request[0..-33]
      [message, iv, mac]
    end

    def cbc_mac(msg, iv)
      Chal49.cbc_mac(msg, @key, iv)
    end
  end

  class WebClient
    def initialize(account, key)
      @account = account
      @key = key
    end

    def generate_transfer_request(from_id, to_id, amount)
      raise "Can only sign messages from own account" unless from_id == @account
      msg = "from=#{from_id}&to=#{to_id.to_i}&amount=#{amount.to_i}"
      iv = Random::DEFAULT.bytes(16)
      mac = Chal49.cbc_mac(msg, @key, iv)
      (msg + iv + mac)
    end
  end

   def self.cbc_mac(msg, key, iv)
      AES.encrypt_cbc(msg, key, iv)[-16..-1]
    end
 end
