class YuletideParser < Parser

  def title
    if title_header = meta_block.css("h2")[0]
      title_header.inner_html
    else
      (doc/"title").inner_html
    end
  end

  def creators(page)
    if match = page.url.match(/archive\/(?<filename>[0-9]+\/.*)\.html/)
      filename = match[:filename]
      author_url = "http://yuletidetreasure.org/cgi-bin/files/get_author.cgi?filename=#{filename}"
      author_page = Scraper.scrape(author_url)
      email = name = ""
      if match = author_page.match(/^EMAIL: (?<email>.*)$/)
        email = match[:email]
      end
      if match = author_page.match(/^NAME: (?<name>.*)/)
        name = match[:name]
      end
      [{ name: name, email: email }]
    end
  end

  def meta
    return unless meta_block.present?
    tags = ['yuletide']
    if match = meta_block.to_html.match(meta_regex)
      fandom    = match[:fandom]
      recipient = match[:recipient]
      challenge = match[:challenge]
      year      = match[:year]

      if challenge == "Yuletide"
        tags << "challenge:Yuletide #{year}"
        date = DateFormatter.format "#{year}-12-25"
      else
        tags << "challenge:NYR #{year}"
        date = DateFormatter.format "#{year}-01-01"
      end

      metadata = { 
        revised_at: date,
        fandoms: fandom, 
        freeforms: tags.join(", "),
        recipients: recipient
      }

      if notes = meta_block.css("p")[0]
        metadata[:notes] = notes.inner_html
      end
    end
  end

  def content
    remove_comment_links
    content_table.inner_html
  end

  def meta
    page = get_search_page
    meta_doc = Nokogiri.parse(page)
    summary = meta_doc.css('dd.summary') ? meta_doc.css('dd.summary').first.content : ""
    metadata = MetadataParser.new(page).parse
    metadata.merge(summary: summary)
  end

  def get_search_page
    search_title = search_string(title)
    search_author = creators.present? ? search_string(creators.first[:name]) : ""
    search_recipient = search_string(recipient)

    search_url = "http://www.yuletidetreasure.org/cgi-bin/search.cgi?" +
                  "Recipient=#{search_recip}&Title=#{search_title}&Author=#{search_author}&NumToList=0"
    Scraper.scrape(search_url) rescue ""
  end

  def search_string(str)
    str ||= ""
    str.gsub(/[^\w]/, ' ').gsub(/\s+/, '+')
  end

  def content_table
    content_table = (doc/"table[@class='form']/tr/td[2]")
  end

  def meta_regex
    /Fandom:\s*?<a .*?>(?<fandom>.*?)<\/a>.*?Written for: (?<recipient>.*) in the (?<challenge>Yuletide|New Year Resolutions) (?<year>\d*) Challenge.*?by <a .*?>(?<creator>.*?)<\/a>/im
  end

  def meta_block
    @meta_block ||= content_table.css("center")[0].remove
  end

  def remove_comment_links
    # Try to remove the comment links at the bottom
    comment_block = content_table.css("center")[-1]
    if comment_block && comment_block.to_html.match(/<!-- COMMENTLINK START -->/)
      centers[-1].remove
    end
  end

end
