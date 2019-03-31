# Defines categories for jobs,
#   for instance, Developer and CTO could be in a same cateogry: Tech.
class JobCategory < ApplicationRecord
  # Relations
  has_many :jobs
  has_many :opportunities, through: :jobs

  # Validations
  validates :name, presence: true, uniqueness: true

  #--------------------- Class Methods ---------------------#

  # Returns a job category matching criteria
  # If it doesn't exist, it will create it
  def self.find_or_create(name:)
    find_or_create_by(name: name)
  end
end
