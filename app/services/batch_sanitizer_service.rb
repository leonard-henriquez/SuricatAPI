# Service object for sanitizing hash
class BatchSanitizerService
  #--------------------- Methods ---------------------#

  # Create service object with all the parameters
  def initialize(values, parameters_types, default_values = {})
    @values = values.to_h.symbolize_keys
    @parameters_types = parameters_types.to_h.symbolize_keys
    @default_values = default_values.to_h.symbolize_keys
  end

  # Call service object
  def call
    values = @default_values.merge(@values)
    types_and_values = values.merge(@parameters_types) { |_key, value, type| { type: type, value: value } }
    types_and_values.map { |k, v| [k, sanitizer(v)] }.compact.to_h
  end

  protected

  def sanitizer(hash)
    return nil unless hash.is_a?(Hash) && hash.key?(:value) && hash.key?(:type)

    sanitizer = SanitizerService.new(hash[:type], hash[:value])
    sanitizer.call
  end
end
