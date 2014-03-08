class FanfictionNetParser < Parser

   # Parses a story from fanfiction.net
    def parse_story_from_ffnet(story)
      work_params = {:chapter_attributes => {}}
      # storytext = clean_storytext((@doc/"#storytext").inner_html)
      storytext = (@doc/"#storytext")
      #remove share area
      divs = storytext.css("div div.a2a_kit")
      if !divs[0].nil?
        divs[0].remove
      end

      storytext = clean_storytext(storytext.inner_html)

      work_params[:notes] = ((@doc/"#storytext")/"p").first.try(:inner_html)

      # put in some blank lines to make it readable in the textarea
      # the processing will strip out the extras
      storytext.gsub!(/<\/p><p>/, "</p>\n\n<p>")

      tags = []
      pagetitle = (@doc/"title").inner_html
      if pagetitle && pagetitle.match(/(.*), an? (.*) fanfic/)
        work_params[:fandom_string] = $2
        work_params[:title] = $1
        if work_params[:title].match(/^(.*) Chapter ([0-9]+): (.*)$/)
          work_params[:title] = $1
          work_params[:chapter_attributes][:title] = $3
        end
      end
      if story.match(/rated:\s*<a.*?>\s*(.*?)<\/a>/i)
        rating = convert_rating($1)
        work_params[:rating_string] = rating
      end

      if story.match(/published:\s*(\d\d)-(\d\d)-(\d\d)/i)
        date = convert_revised_at("#{$3}/#{$1}/#{$2}")
        work_params[:revised_at] = date
      end

      if story.match(/rated.*?<\/a> - .*? - (.*?)(\/(.*?))? -/i)
        tags << $1
        tags << $3 unless $1 == $3
      end

      work_params[:freeform_string] = clean_tags(tags.join(ArchiveConfig.DELIMITER_FOR_OUTPUT))
      work_params[:chapter_attributes][:content] = storytext

      return work_params
    end

  
end
