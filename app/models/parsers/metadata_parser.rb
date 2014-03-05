class MetadataParser

  attr_reader :text, :meta

  MAPPING = {
    title:          'Title',
    notes:          'Notes?',
    summary:        'Summary',
    freeforms:      'Tags?',
    fandoms:        'Fandoms?',
    rating:         'Ratings?|Rated',
    relationships:  'Relationships?|Pairings?',
    revised_at:     'Date|Posted|Posted on|Posted at'
  }

  def initialize(text)
    @text = text
    @meta = {}
  end

  def parse
    clean_up_text
    find_metadata
    map_rating
    format_date
    return meta
  end

  # break up the text with some extra newlines to make matching more likely
  # and strip out some tags
  def clean_up_text
    text.gsub!(/<br/, "\n<br")
    text.gsub!(/<p/, "\n<p")
    text.gsub!(/<\/?span(.*?)?>/, '')
    text.gsub!(/<\/?div(.*?)?>/, '')
  end

  # Find any cases of the given pieces of meta in the given text
  # and return a hash of meta values
  # what this does is look for pattern: (whatever)
  # and then sets meta[:metaname] = whatever
  # eg, if it finds Fandom: Stargate SG-1 it will set meta[:fandom] = Stargate SG-1
  def find_metadata
    MAPPING.each do |metaname, pattern|
      metapattern = Regexp.new("(#{pattern})\s*:\s*(.*)", Regexp::IGNORECASE)
      if text.match(metapattern)
        value = $2
        if value.match(metapattern)
          value = $2
        end
        meta[metaname] = value.strip
      end
    end
    meta
  end

  def map_rating
    meta[:rating] = RatingMapper.map meta[:rating]
  end

  def format_date
    if meta[:revised_at].present?
      meta[:revised_at] = DateFormatter.format meta[:revised_at]
    end
  end

end