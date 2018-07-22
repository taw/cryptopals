class Chal13
  def parse_query(query)
    query.split("&").map{|q|
      q.split("=", 2)
    }.to_h
  end

  def build_query_string(hash)
    hash.map{|k,v|
      k.to_s.tr("&=", "") + "=" + v.to_s.tr("&=", "")
    }.join("&")
  end

  def profile_for(email)
    build_query_string({
      "email" => email,
      "uid" => 10,
      "role" => "user",
    })
  end
end
