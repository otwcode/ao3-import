class DreamwidthParser < JournalParser

  def title
    doc.css("title").inner_html.gsub! /^[^:]+: /, ""
  end

  def content
    body = doc.css("body")
    content_divs = body.css("div#entry")
    if content_divs[0].present?
      # Get rid of the DW metadata table
      content_divs[0].css("table.currents, div#entrysubj").each do |node|
        node.remove
      end
      text = content_divs[0].inner_html
    else
      text = body.inner_html
    end
    text
  end

  def date
    DateFormatter.format doc.css("span.time").inner_text
  end

end