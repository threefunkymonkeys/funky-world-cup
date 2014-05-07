class Hash
  def strip
    self.inject({}) { |res, (key, value)| res[key] = value.strip; res}
  end
end
