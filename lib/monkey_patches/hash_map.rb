class Hash
  def value_map(&blk)
    r = {}
    self.each{|k, v| r[k] = blk.call(v) }
    return r
  end
end
