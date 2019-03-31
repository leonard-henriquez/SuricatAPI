# Service object for grading opportunity for a given suer
class GradeService
  # Constants
  CALCULATION_CONSTANT = Math.log(2)
  POSITION_CONSTANT = 0.9
  MAX_DISTANCE = 30

  #--------------------- Methods ---------------------#

  attr_accessor :user, :opportunity

  # Create service object with all the parameters
  def initialize(user, opportunity)
    @user = user
    @opportunity = opportunity
  end

  # Returns criteria
  def criteria
    @user.criteria
  end

  # Returns characteristics
  def characteristics
    @opportunity.characteristics
  end

  # Return importance_value
  def importances_value
    @user.importances_value
  end

  # Call service object
  def call
    grade = 0
    total_importances_values = 0
    matching = criterium_matching
    matching.each do |key, value|
      next unless importances_value.key?(key)

      # Rails.logger.info "key: #{key}, value: #{value}, importance: #{importances_value[key]}"
      total_importances_values += importances_value[key]
      grade += value * importances_value[key]
    end
    # Rails.logger.info "total importances: #{total_importances_values}"
    # Rails.logger.info "grade: #{(grade * 100).fdiv(total_importances_values)}"
    (grade * 100).fdiv(total_importances_values).to_i
  rescue StandardError => e
    Rails.logger.info '%%%%%% Grade calculation failed %%%%%%'
    Rails.logger.info e.inspect
    log_error
    0
  end

  # Debugger
  def log_errror
    Rails.logger.info "characteristics: #{characteristics}"
    Rails.logger.info "criteria: #{criteria}"
    Rails.logger.info "criterium_matching: #{criterium_matching}"
    Rails.logger.info "importances_value: #{importances_value}"
  end

  # Check if user's criteria match opportunity' characteristics
  def criterium_matching
    matching = {}

    Criterium.types.each do |criterium, type|
      next unless characteristics.key?(criterium) && criteria.key?(criterium)

      value = characteristics[criterium]
      range = criteria[criterium]
      next if value.nil? || range.nil?

      match = check_matching(type, value, range)

      matching[criterium] = match unless match.nil?
    end

    matching
  end

  protected

  def check_matching(type, value, range)
    return 0 if range.is_a?(Array) && range.empty?

    case type
    when :integer
      distance(value, range)
    when :enum
      position(value, range)
    when :string
      position(value, range)
    when :location
      dist = range.map { |criteria_value| Geocoder::Calculations.distance_between(criteria_value, value) }.min
      distance(dist, MAX_DISTANCE, true)
    end
  end

  def position(value, range)
    return 0 unless range.include?(value)

    pseudo_rank = POSITION_CONSTANT**range.index(value)
    Math.exp(CALCULATION_CONSTANT * pseudo_rank) - 1
  end

  def distance(value, reference, negative = false)
    if negative
      value = -value
      reference = -reference
    end

    return 1 if value >= reference
    return 0 if value <= 0

    Math.exp(CALCULATION_CONSTANT * value.fdiv(reference)) - 1
  end
end
