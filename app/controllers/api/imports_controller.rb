class Api::ImportsController < Api::BaseController
  
  def create
    @work = Import.new(import_params).perform
    if @import.perform
    render json: import_params
  end
  
  def import_params
    params.require('import').permit(:url, :chapter_urls)
  end
  
end