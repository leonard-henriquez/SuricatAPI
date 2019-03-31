# Defines a UserOpportunity,
#   a new UserOpportunity is created every time a user saves an opportunity (a job offer).
class UserOpportunity < ApplicationRecord
  # Enums
  enum status: [:review, :pending, :applied, :trash]

  # Relations
  belongs_to :user
  belongs_to :opportunity
  has_one :job, through: :opportunity
  has_one :company, through: :opportunity
  has_one :sector, through: :opportunity

  # Validations
  validates :user, presence: true
  validates :opportunity, presence: true
  validates :personnal_grade, presence: true

  # Triggers
  after_initialize :init
  before_save :grade_calculation

  #--------------------- Delegations ---------------------#

  # Creates delegations for Opportunity
  # Allows to call UserOpportunity.first.job_description
  (Opportunity.attribute_names - attribute_names).each do |attr|
    delegate attr.to_sym, to: :opportunity, allow_nil: true
  end

  # Creates delegations for Job, Company and Sector
  # Allows to call UserOpportunity.first.Job
  [Job, Company, Sector].each do |obj|
    (obj.attribute_names - attribute_names).each do |attr|
      object_name = obj.name.underscore
      delegate attr.to_sym, to: object_name, allow_nil: true, prefix: true
    end
  end

  #--------------------- Class Methods ---------------------#

  # Returns a user opportunity matching criteria
  # If it doesn't exist, it will create it
  def self.find_or_create(user:, opportunity:, params: nil)
    item = find_by(user: user, opportunity: opportunity)
    return item unless item.nil?

    raise ArgumentError, 'Missing params' if params.nil?

    UserOpportunity.create(
      user: user,
      opportunity: opportunity,
      personnal_grade: params[:stars]
    )
  end

  #--------------------- Methods ---------------------#

  protected

  # Automatically triggered by save
  # It recalculates the automatic grade
  def grade_calculation
    grade_calculator = GradeService.new(user, opportunity)
    self.automatic_grade = grade_calculator.call
  end

  # Sets defaults values
  def init
    self.status ||= :review
    self.personnal_grade ||= 0
  end
end
