class EfictionScraper < Scraper
  
  # grab all the chapters of a story from an efiction-based site
  def get_pages
    pages = []
    url = urls.first
    if url.match(/^(.*)\/.*viewstory\.php.*sid=(\d+)($|&)/i)
      site = $1
      storyid = $2
      chapter = 1
      Timeout::timeout(STORY_DOWNLOAD_TIMEOUT) {
        until chapter > MAX_CHAPTER_COUNT do
          url = "#{site}/viewstory.php?action=printable&sid=#{storyid}&chapter=#{chapter}"
          body = get_page(url)
          break if stop_paging?(body)
          pages << body
          chapter += 1
        end
      }
    end
    pages
  end
  
  def stop_paging?(text)
    # This is what you get when...?
    no_data = /<div class='chaptertitle'> by <\/div>/
    # This is what you get when you go past the last existing chapter
    empty_chapter = /Chapter : /
    access_denied = /Access denied./
    
    text.nil? || text.match(no_data) || text.match(access_denied) || text.match(empty_chapter)
  end
  
end