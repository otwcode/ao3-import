# Parses a story from livejournal or a livejournal equivalent (eg, dreamwidth, insanejournal)
# Assumes that we have downloaded the story from one of those equivalents (ie, we've downloaded
# it in format=light which is a stripped-down plaintext version.)
class JournalParser < Parser

  def title
    title = doc.css("title").inner_html
    title.gsub /^[^:]+: /, ""
  end

  # in LJ "light" format, the story contents are in the second div
  # inside the body.
  def content
    body = doc.css("body")
    content = body.css("article.b-singlepost-body").inner_html
    content = body.inner_html if content.empty?
  end

  def date
    DateFormatter.format doc.css("span.b-singlepost-author-date")
  end

  def meta
    MetadataParser.parse_text content
  end

  def creators(page)
    return unless page.url.match(expected_url_format)
    name = match[:name]
    site = match[:site]
    name = poster_name if name == "community"
    profile_url = "http://#{name}.#{site}/profile"
    email = get_email_from_profile(profile_url) || "#{name}@#{site}"
    [{ name: name, email: email }]
  end

  def expected_url_format
    /^(http:\/\/)?(?<name>[^\.]*).(?<site>livejournal.com|dreamwidth.org|insanejournal.com|journalfen.net)/
  end

  def poster_name
    doc.xpath("/html/body/div[2]/div/div/div/table/tbody/tr/td[2]/span/a[2]/b").content
  end

  def get_profile(profile_url)
    Scraper.scrape(profile_url)
  end

  def get_email_from_profile(profile_url)
    page = get_profile(profile_url)
    profile_doc = Nokogiri.parse(page)
    contact = profile_doc.css('div.contact').inner_html
    match = contact.match(/(?<email>\w+@\w+\.\w+)/)
    match ? match[:email] : nil
  end
  
end