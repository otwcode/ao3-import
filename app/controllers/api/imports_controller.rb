class Api::ImportsController < Api::BaseController
  
  def create
    render json: import_params
  end
  
  def import_params
    params.require('import').permit(:url, :chapter_urls)
  end
  
end