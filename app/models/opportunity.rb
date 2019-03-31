# Defines a job offer posted by a company for a specific job.
# You should understand opportunity as a job offer,
#   although we chose to name it differently to reflect the customer centricity.
# An opportunity is not in it self related to a user,
#   but there is a many to many relation with users through the UserOpportunity model.
class Opportunity < ApplicationRecord
  # Enums
  enum contract_type: [:internship, :vie, :graduate_program, :fixed_term, :full_time, :apprenticeship, :other]

  # Relations
  belongs_to :job, optional: true
  belongs_to :company, optional: true
  belongs_to :sector, optional: true
  has_one :job_category, through: :job
  has_one :sector_category, through: :sector
  has_many :user_opportunities, dependent: :destroy
  has_many :users, through: :user_opportunities

  # Validations
  validates :url, presence: true, uniqueness: true
  validates :job_description, presence: true

  # Triggers
  after_validation :geocode, if: :will_save_change_to_location?
  before_save :set_default_values

  # Transform string location into coordinates location
  geocoded_by :company_location

  #--------------------- Delegations ---------------------#

  [Job, Company, Sector].each do |obj|
    (obj.attribute_names - attribute_names).each do |attr|
      object_name = obj.name.underscore
      delegate attr.to_sym, to: object_name, allow_nil: true, prefix: true
    end
  end

  #--------------------- Class Methods ---------------------#

  # Returns an opportunity matching criteria
  # If it doesn't exist, it will create it
  def self.find_or_create(url:, params: nil)
    item = find_by(url: url)
    return item unless item.nil?

    raise ArgumentError, 'Missing params' if params.nil?

    opportunity_params = filter_params(params)
    dependencies_params = create_dependencies(params)
    create(opportunity_params.merge(dependencies_params))
  end

  # Sub method for find_or_create
  def self.create_dependencies(params)
    dependencies = {}

    unless params[:company_name].nil?
      dependencies[:company] = Company.find_or_create(
        name: params[:company_name],
        structure: params[:company_structure]
      )
    end

    unless params[:job_name].nil?
      dependencies[:job] = Job.find_or_create(
        name: params[:job_name],
        category: params[:job_category]
      )
    end

    unless params[:sector_name].nil?
      dependencies[:sector] = Sector.find_or_create(
        name: params[:sector_name],
        category: params[:sector_category]
      )
    end

    dependencies
  end

  # Sub method for find_or_create
  def self.filter_params(params)
    # try to fill all the attributes different than id, company_id, job_id, and sector_id with the $params
    all_params = new.attributes.keys
    puts params
    params = params.select { |x| all_params.include?(x.to_s) && x !~ /id$/ }
    puts params
    params
  end

  #--------------------- Methods ---------------------#

  # Returns the company type as an id number and not a symbol
  def contract_type_id
    contract_type_before_type_cast
  end

  # Provides the most specific location for the geocoder
  def company_location
    company.nil? ? location : [company.name, location].compact.join(', ')
  end

  # Returns the characteristics of an opportunity
  def characteristics
    {
      contract_type: contract_type_id,
      company_structure: company.nil? ? nil : company.structure_id,
      sector_name: sector_id,
      job_name: job_id,
      location: [(latitude || 0).to_f, (longitude || 0).to_f],
      salary: salary
    }
  end

  protected

  def set_default_values
    self.logo ||= '/images/default_company_logo.png'
  end
end
