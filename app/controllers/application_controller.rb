# Parent class for controllers
class ApplicationController < ActionController::API
  before_action :set_headers

  # Set the right content type for json respecting https://jsonapi.org/
  def set_headers
    response.headers['Content-Type'] = 'application/vnd.api+json'
  end
end
