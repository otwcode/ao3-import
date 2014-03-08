class FanfictionNetScraper < Scraper

  # grab all the chapters of the story from ff.net
  def get_pages
    pages = []
    url = urls.first
    raise ImportDeniedError if url.match(/story_preview/) || url.match(/secure/)
    if url.match(/^(.*fanfiction\.net\/s\/[0-9]+\/)([0-9]+)(\/.*)$/i)
      base_url= $1
      title = $3
      chapter = 1
      Timeout::timeout(STORY_DOWNLOAD_TIMEOUT) {
        until chapter > MAX_CHAPTER_COUNT do
          url = "#{base_url}#{chapter.to_s}#{title}"
          body = get_page(url)
          break if body.nil? || body.match(/FanFiction\.Net Message/)
          pages << Hashie::Mash.new(url: url, text: body)
          chapter += 1
        end
      }
    end
    pages
  end

end