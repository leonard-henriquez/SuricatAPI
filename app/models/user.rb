# Defines a user.
class User < ApplicationRecord
  # Relations
  has_many :importances, dependent: :destroy
  has_many :criteria, through: :importances
  has_many :events, dependent: :destroy
  has_many :user_opportunities, dependent: :destroy
  has_many :opportunities, through: :user_opportunities

  # Triggers
  before_validation :sanitize_content, on: [:create, :update]
  after_create :create_importances

  #--------------------- Methods ---------------------#

  # Cleans the names for proper capilization
  def sanitize_content
    self.first_name = first_name.split.map(&:capitalize).join(' ') unless first_name.nil?
    self.last_name = last_name.split.map(&:capitalize).join(' ') unless last_name.nil?
  end

  # Creates the six importances when a user is created
  # Because all user should have six importances
  def create_importances
    importance_names = Importance.names.keys.map(&:to_sym)
    # returns [:contract_type, :company_structure, :sector_name, :job_name, :location, :salary]
    importance_names.each do |importance_name|
      Importance.create(user: self, name: importance_name, value: 50)
    end
  end

  # Retrieves the six imortances of a user
  def importances_value
    importances.map { |i| [i.name.to_sym, i.value || 0] }.to_h
  end

  # Retrieves the list of criteria of a user
  def criteria
    criteria_list = {}
    importances.each do |i|
      name = i.name.to_sym
      value = i.criteria.map(&:value.to_proc)
      criteria_list[name] = value
    end

    cleaned_list = CriteriaStandardizerService.new(criteria_list, true)
    cleaned_list.call
  end
end
