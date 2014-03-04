class Import
  
  attr_reader :urls
  
  # Sites with custom scrapers/parsers
  SOURCES = {
    journal:           '((live|dead|insane)?journal(fen)?\.com)',
    dreamwidth:        'dreamwidth\.org',
    yuletide:          'yuletidetreasure\.org',
    fanfiction_net:    '(^|[^A-Za-z0-9-])fanfiction\.net',
    minotaur:          '(bigguns|firstdown).slashdom.net',
    deviantart:        'deviantart\.com',
    lotr_fanfiction:   'lotrfanfiction\.com',
    twilight_archives: 'twilightarchives\.com',
    efiction:          'viewstory\.php'
  }
  
  def initialize(attrs)
    chapter_urls  = attrs[:chapter_urls] || []
    work_url      = attrs[:url] || chapter_urls.shift
    @urls         = [work_url] + chapter_urls
  end
  
  def perform
    pages = scraper.scrape(urls)
    parser.parse(pages)
  end
  
  def scraper
    "#{site_prefix}Scraper".classify rescue Scraper
  end
  
  def parser
    "#{site_prefix}Parser".classify rescue Parser
  end
  
  def site_prefix
    SOURCES.keys.each do |source|
      pattern = Regexp.new(SOURCES[source], Regexp::IGNORECASE)
      if urls.first.match(pattern)
        return source.to_s.titleize
      end
    end
    ""
  end
  
end