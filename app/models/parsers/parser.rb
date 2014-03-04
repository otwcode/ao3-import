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
    doc = Nokogiri::HTML.parse(page, nil, encoding) rescue ""
    work_attributes = {
      title:      self.title,
      revised_at: self.date,
      chapters:   [{ content: self.content }]
    }
    work_attributes.merge!(meta)
    work_attributes
  end
  
  def parse_chapter_page(page)
    doc = Nokogiri::HTML.parse(page, nil, encoding) rescue ""
    { content: self.content }
  end
  
  private
  
  def title
    doc.css("title").inner_html
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
    Date.today
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
  
  def convert_revised_at(date_string)
    begin
      date = nil
      if date_string.match(/^(\d+)$/)
        # probably seconds since the epoch
        date = Time.at($1.to_i)
      end
      date ||= Date.parse(date_string)
      date > Date.today ? '' : date
    rescue ArgumentError, TypeError
      return ''
    end
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