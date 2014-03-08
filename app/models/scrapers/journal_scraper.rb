class JournalScraper < Scraper

  def get_pages
    urls.map do |url|
      page = get_page(url)
      if page.match(/adult_check/)
        page = get_adult_page(url)
      end
      Hashie::Mash.new(url: url, text: page)
    end
  end
  
  def get_adult_page(url)
    Timeout::timeout(STORY_DOWNLOAD_TIMEOUT) {
      begin
        agent = Mechanize.new
        form = agent.get(url).forms.first
        page = agent.submit(form, form.buttons.first) # submits the adult concepts form
        text = page.body.force_encoding(agent.page.encoding)
      rescue
        text = ""
      end
    }
    text
  end
  
  def formatted_url(url)
    url.gsub!(/\#(.*)$/, "") # strip off any anchor information
    url.gsub!(/\?(.*)$/, "") # strip off any existing params at the end
    url.gsub!('_', '-') # convert underscores in usernames to hyphens
    url += "?format=light" # go to light format
    super
  end
  
end