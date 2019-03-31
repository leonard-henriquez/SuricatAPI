# Service object for sanitizing with regex
class RegexSanitizerService
  #--------------------- Methods ---------------------#

  # Create service object with all the parameters
  def initialize(value, regex_table, default_sanitized_value = nil)
    @value = value.to_s.downcase
    @regex_table = regex_table
    @default_sanitized_value = default_sanitized_value
  end

  # Call service object
  def call
    @regex_table.each do |sanitized_value, regexes|
      regexes = [regexes] unless regexes.is_a? Array
      return sanitized_value if Regexp.union(regexes).match?(@value)
    end
    @default_sanitized_value
  end
end
