# Defines JSON serializer for class User
class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :first_name, :last_name, :email

  attribute :token do |_, params|
    params[:token]
  end
end
