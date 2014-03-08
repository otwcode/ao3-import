class MinotaurParser < Parser

    # custom author parser for the whitfic and grahamslash archives we're rescuing
    # known problem: this will only find the first author for a given story, not coauthors
    def creators(page)
      location = page.url
      # get the index page of the archive
      # and the relative link for story we are downloading
      if location =~ /firstdown/
        author_index = Scraper.scrape("http://firstdown.slashdom.net/authors.html")
        storylink = location.gsub("http://firstdown.slashdom.net/", "")
      elsif location =~ /bigguns/
        author_index = Scraper.scrape("http://bigguns.slashdom.net/stories/authors.html")
        storylink = location.gsub("http://bigguns.slashdom.net/stories/", "")
      end
      index_doc = Nokogiri.parse(author_index)

      # find the author just before the story
      index_doc.search("a").each do |node|
        if node[:href] =~ /mailto:(.*)/
          authornode = node
        end
        if node[:href] == storylink
          # the last-found authornode is the right one
          break
        end
      end
      email = authornode[:href].gsub("mailto:", '')
      name = authornode.inner_text

      [{ name: name, email: email}]
    end
  
end
