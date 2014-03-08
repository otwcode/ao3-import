class ModifiedEfictionParser < EfictionParser

    def parse_story_from_modified_efiction(story, site = "")
      work_params = {:chapter_attributes => {}}
      storytext = @doc.css("div.chapter").inner_html
      storytext = clean_storytext(storytext)
      work_params[:chapter_attributes][:content] = storytext
      
      work_params[:title] = @doc.css("html body div#pagetitle a").first.inner_text.strip
      work_params[:chapter_attributes][:title] = @doc.css(".chaptertitle").inner_text.gsub(/ by .*$/, '').strip
      
      # harvest data
      info = @doc.css(".infobox .content").inner_html

      if info.match(/Summary:.*?>(.*?)<br>/m)
        work_params[:summary] = clean_storytext($1)
      end      

      infotext = @doc.css(".infobox .content").inner_text      

      # Turn categories, genres, warnings into freeform tags
      tags = []
      if infotext.match(/Categories: (.*) Characters:/)
        tags += $1.split(',').map {|c| c.strip}.uniq unless $1 == "None"
      end
      if infotext.match(/Genres: (.*)Warnings/)
        tags += $1.split(',').map {|c| c.strip}.uniq unless $1 == "None"
      end
      if infotext.match(/Warnings: (.*)Challenges/)
        tags += $1.split(',').map {|c| c.strip}.uniq unless $1 == "None"
      end
      work_params[:freeform_string] = clean_tags(tags.join(ArchiveConfig.DELIMITER_FOR_OUTPUT))

      # use last updated date as revised_at date
      if site == "lotrfanfiction" && infotext.match(/Updated: (\d\d)\/(\d\d)\/(\d\d)/)
        # need yy/mm/dd to convert
        work_params[:revised_at] = convert_revised_at("#{$3}/#{$2}/#{$1}") 
      elsif site == "twilightarchives" && infotext.match(/Updated: (.*)$/)
        work_params[:revised_at] = convert_revised_at($1)
      end
      

      # get characters
      if infotext.match(/Characters: (.*)Genres:/)
        work_params[:character_string] = $1.split(',').map {|c| c.strip}.uniq.join(',') unless $1 == "None"
      end

      # save the readcount
      readcount = 0
      if infotext.match(/Read: (\d+)/)
        readcount = $1
      end
      work_params[:notes] = (readcount == 0 ? "" : "<p>This work was imported from another site, where it had been read #{readcount} times.</p>")

      # story notes, chapter notes, end notes
      @doc.css(".notes").each do |note|
        if note.inner_html.match(/Story Notes/)
          work_params[:notes] += note.css('.noteinfo').inner_html
        elsif note.inner_html.match(/(Chapter|Author\'s) Notes/)
          work_params[:chapter_attributes][:notes] = note.css('.noteinfo').inner_html
        elsif note.inner_html.match(/End Notes/)
          work_params[:chapter_attributes][:endnotes] = note.css('.noteinfo').inner_html
        end
      end
      
      if infotext.match(/Completed: No/)
        work_params[:complete] = false
      else
        work_params[:complete] = true
      end

      return work_params
    end
  

end