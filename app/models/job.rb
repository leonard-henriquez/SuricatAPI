# Defines a job
#   for instance, CTO.
# An opportunity is most likey to be connected to a job.
class Job < ApplicationRecord
  # Relations
  belongs_to :job_category, optional: true
  has_many :opportunities
  has_many :user_opportunities, through: :opportunities

  # Aliases
  alias_attribute :category, :job_category

  # Validations
  validates :name, presence: true, uniqueness: true

  #--------------------- Class Methods ---------------------#

  # Returns category of this job
  def self.category
    (to_s + 'Category').constantize
  end

  # Returns a job matching criteria
  # If it doesn't exist, it will create it
  def self.find_or_create(name:, category: nil)
    item = find_by(name: name)
    return item unless item.nil?

    category = self.category.find_or_create(name: category) unless category.nil?
    create(name: name, category: category)
  end
end
