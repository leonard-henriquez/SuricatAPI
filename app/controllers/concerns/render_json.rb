# Include this concern in your ApplicationController
# Must implement links_object and paginate_collection
module RenderJson
  extend ActiveSupport::Concern

  included do
    # method added in controller to rend serialized json build with fast_jsonapi
    def render_json(*args)
      options = args.extract_options!
      collection = args.first
      # collection = paginate_collection(collection) if options[:paginate] == true
      serializer_key = options[:serializer] || collection_type(collection)
      serializer_class_name = serializer_type(serializer_key)
      serializer_options = build_fast_jsonapi_options(options)

      # if options[:links] == true
      #   serializer_options[:links] = links_object(collection)
      # end

      serialized_collection = serializer_class_name.new(collection, serializer_options)
      status = options[:status] || :ok

      render json: serialized_collection.serialized_json, status: status
    end
  end

  private

  def collection_type(collection)
    collection.klass.base_class.name
  end

  def serializer_type(serializer_key)
    (serializer_key + 'Serializer').constantize
  end

  def links_object(collection)
    # Generate your top-level links object here
  end

  def paginate_collection(collection)
    # Implement your pagination here
  end

  def build_fast_jsonapi_options(options)
    json_options = {
      params: options[:params] || {},
      meta: options[:meta] || {}
    }

    # json_options[:params][:current_user] = current_user

    includes = options[:include]
    json_options[:include] = includes_array(includes) if includes.present?

    json_options
  end

  def includes_array(includes)
    includes.is_a?(Array) ? includes : [includes]
  end
end
