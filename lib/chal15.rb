class Chal15
  def strip_padding(str)
    pad_size = str[-1].ord
    padding = str[-pad_size..-1].unpack("C*")
    raise "Bad padding" unless padding == [pad_size] * pad_size
    str[0...-pad_size]
  end
end
