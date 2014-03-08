class TwilightArchiveParser < ModifiedEfictionParser

  def meta
    super.merge(fandom: "Twilight")
  end

end
