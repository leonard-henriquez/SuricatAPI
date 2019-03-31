# Please, read first the documentation of importance.
#
# Defines a criterium which is the concrete expression of an importance.
# A criterium expresses "{user} wants a job where {criterium.type} is {criterium.value}",
#   for instance, "I want a job where contract type is fulltime".
class Criterium < ApplicationRecord
  # Relations
  # Criterium belongs to a user through imortance
  belongs_to :importance

  #--------------------- Class Methods ---------------------#

  # Returns the possible types of criterium
  def self.types
    {
      contract_type: :enum,
      company_structure: :enum,
      sector_name: :enum,
      job_name: :enum,
      location: :location,
      salary: :integer
    }
  end
end
