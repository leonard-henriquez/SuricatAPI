# Defines an importance.
# Every user as six importances:
#   contract_type, company_structure, sector_name, job_name, location, salary.
# They all have relative value to weight how much this factor is important for him/her.
#
# Each of this importance will also take specific values that are named 'criterium':
#   a criterium is the concrete expression of an importance.
class Importance < ApplicationRecord
  # Enums
  enum name: [:contract_type, :company_structure, :sector_name, :job_name, :location, :salary]

  # Relations
  belongs_to :user
  has_many :criteria, dependent: :destroy

  # Sorting
  default_scope { order(:name) }
end
