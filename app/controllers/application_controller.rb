# Parent class for controllers
class ApplicationController < ActionController::API
  before_action :set_headers

  # Set the right content type for json respecting https://jsonapi.org/
  def set_headers
    response.headers['Content-Type'] = 'application/vnd.api+json'
  end

  # Checks if the request has an header Authorization with the right token
  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = JsonWebToken.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end
end
