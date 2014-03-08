class Scraper
  
  attr_accessor :urls
  
  REDIRECT_LIMIT          = 10
  DOWNLOAD_TIMEOUT        = 60
  STORY_DOWNLOAD_TIMEOUT  = 60
  MAX_CHAPTER_COUNT       = 200
  CONNECTION_ERRORS       = [Errno::ECONNREFUSED, SocketError, EOFError]
  
  def self.scrape(urls)
    self.new(urls).get_pages
  end
  
  def initialize(urls)
    @urls = urls.map{ |url| formatted_url(url) }
  end
  
  def get_pages
    urls.map { |url| get_page(url) }
  end
  
  def get_page(url, redirect_limit = REDIRECT_LIMIT)
    page = ""
    Timeout::timeout(DOWNLOAD_TIMEOUT) {
      begin
        response = Net::HTTP.get_response(url)
        case response
        when Net::HTTPSuccess
          page = response.body
        when Net::HTTPRedirection
          if redirection_limit > 0
            page = get_page(response['location'], redirect_limit - 1) 
          end
        end
      rescue *CONNECTION_ERRORS
        raise ImportConnectionError
      end
    }
    Hashie::Mash.new(url: url, text: page)
  end
  
  def formatted_url(url)
    UrlFormatter.new(url).standardized
  end

  class ImportConnectionError < StandardError; end
  class ImportDeniedError < StandardError; end
  
end