class LotrFanfictionParser < ModifiedEfictionParser
  
  def meta
    super.merge(fandom: "Lord of the Rings")
  end

end
