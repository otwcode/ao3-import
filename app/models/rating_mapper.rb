class RatingMapper

  class << self

    def map(rating)
      rating ||= ""
      case rating.downcase
      when explicit then "Explicit"
      when mature   then "Mature"
      when teen     then "Teen And Up Audiences"
      when general  then "General Audiences"
      else "Not Rated"
    end

    def explicit
      /^(nc-?1[78]|x|ma|explicit)/
    end

    def mature
      /^(r|m|mature)/
    end

    def teen
      /^(pg-?1[35]|t|teen)/
    end

    def general
      /^(pg|g|k+|k|general audiences)/
    end

  end

end