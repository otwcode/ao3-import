class DeviantartParser < Parser

	def title
    title = page_title
    body.css("div.dev-title-container h1 a").each do |node|
      if node["class"] != "u"
        title = node.inner_html
      end
    end
    title
	end

  def notes
    body = doc.css("body")
    content_divs = body.css("div.text-ctrl div.text")
    content_divs[0].nil? ? nil : content_divs[0].inner_html
  end

  def meta
    metadata = MetadataParser.new(notes).parse
    tags = doc.css("div.dev-about-cat-cc a.h").map { |node| node.inner_html }
    metadata.merge(freeforms: tags.join(", "))
  end
    
  def date
    details = doc.css("div.dev-right-bar-content span[title]")
    details[0].nil? ? nil : DateFormatter.format details[0].inner_text
  end

  def content
    art_content || text_content
  end

  def art_content
    body = doc.css("body")
    image_full = body.css("div.dev-view-deviation img.dev-content-full")
    if image_full[0].present?
      "<center><img src=\"#{image_full[0]["src"]}\"></center>"
    else
      nil
    end
  end

  # Find the fic text if it's fic 
  # (needs the id for disambiguation, the "deviantART loves you" bit in the footer has the same class path)
  def text_content
    body = doc.css("body")
    text_table = body.css(".grf-indent > div:nth-child(1)")[0]
    if text_table.present?
      remove_metadata(text_table)
      remove_creator(text_table)
      text_table.inner_html
    end
  end

  # Try to remove some metadata (title and author) from the work's text, if possible
  # Try to remove the title: if it exists, and if it's the same as the browser title
  def remove_metadata(content_node)
    extra_meta = content_node.css("h1")[0]
    if extra_meta.present? && page_title.match(extra_meta.text)
      extra_meta.remove
    end
  end

  # Try to remove the author: if it exists, and if it follows a certain pattern
  def remove_creator(content_node)
    creator_name = content_node.css("small")[0]
    if creator_name.present? && creator_name.inner_html.match(/by ~.*?<a class="u" href=/m)
      creator_name.remove
    end
  end
  
  def page_title
    doc.css("title").inner_html.gsub /\s*on deviantart$/i, ""
  end

end
