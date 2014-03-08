class Parser
  
  attr_reader :first_page, :chapters, :encoding
  attr_accessor :doc
  
  def self.parse(pages, encoding=nil)
    self.new(pages, encoding).parse
  end
  
  def initialize(pages, encoding=nil)
    @first_page = pages.shift
    @chapters = pages
    @encoding = encoding
  end
  
  def parse
    work_data = parse_work_page(first_page)
    chapters.each do |chapter|
      work_data[:chapters] << parse_chapter_page(chapter)
    end
    work_data
  end
  
  def parse_work_page(page)
    doc = Nokogiri::HTML.parse(page.text, nil, encoding) rescue ""
    convert_relative_links(page.url)
    work_attributes = {
      title:      self.title,
      creators:   self.creators(page.url),
      revised_at: self.date,
      chapters:   [{ content: self.content }]
    }
    work_attributes.merge!(meta)
    work_attributes
  end
  
  def parse_chapter_page(page)
    doc = Nokogiri::HTML.parse(page.text, nil, encoding) rescue ""
    convert_relative_links(page.url)
    { content: self.content }
  end

  # Try to convert all relative links to absolute
  def convert_relative_links(url)
    base_url = doc.css('base').present? ? doc.css('base')[0]['href'] : url.split('?').first      
    return if base_url.blank?
    doc.css('a').each do |link|
      link['href'] = converted_link(base_url, link['href'])
    end
  end

  def converted_link(base_url, path)
    return path if path.blank?
    query_regex = /(\?.*)$/
    query = path.match(query_regex) ? $1 : ''
    begin
      URI.join(base_url, path.gsub(query_regex, '')).to_s + query
    rescue
      path
    end
  end
  
  def title
    doc.css("title").inner_html
  end

  def creators(url)
    nil
  end

  def content
    text = doc.css("body").inner_html if doc.css("body")
    if text.blank?
      text = doc.css("html").inner_html
    end
    if text.blank?
      # just grab everything
      text = page
    end
    set_encoding(text)
    text
  end

  def date
    Time.now
  end

  def meta
    header = doc.css("head").inner_html if doc.css("head")
    text = doc.css("body").inner_html if doc.css("body")

    metadata = {}
    if header.present?
      metadata.merge! MetadataParser.parse_text(header)
    end
    if text.present?
      metadata.merge! MetadataParser.parse_text(text)
    end

    metadata
  end
  
  # We clean the text as if it had been submitted as the content of a chapter
  def set_encoding(text)
    unless text.encoding.name == "UTF-8"
      text = text.encode("UTF-8", 
        invalid: :replace, 
        undef: :replace, 
        replace: ""
      )
    end
  end
  
end