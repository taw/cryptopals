class Chal31
  class Server
    def initialize
      @data = "All your base are belong to us\n"
      @key = Random::DEFAULT.bytes(32)
      @mac = OpenSSL::HMAC.hexdigest("SHA256", @key, @data)
    end

    def call(env)
      signature = Rack::Utils.parse_nested_query(env["QUERY_STRING"])["signature"] || ""
      if insecure_compare(@mac, signature)
        [200, {"Content-Type" => "text/plain"}, @data]
      else
        [500, {"Content-Type" => "text/plain"}, "Bad MAC\n"]
      end
    end

    def insecure_compare(a, b)
      i = 0
      while true
        sleep 0.05
        return false if a[i] != b[i]
        return true if a[i] == nil and b[i] == nil
        i += 1
      end
    end
  end
end
