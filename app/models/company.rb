# Defines a company, for instance Facebook.
# A company has a name and a structure type (SME, Start up, etc.).
# An opportunity is most likey to be connected to a company.
class Company < ApplicationRecord
  # Enums
  enum structure: [:large_company, :sme, :start_up, :others]

  # Relations
  has_many :opportunities
  has_many :user_opportunities, through: :opportunities

  # Validations
  validates :name, presence: true, uniqueness: true

  #--------------------- Class Methods ---------------------#

  # Returns a company matching criteria
  # If it doesn't exist, it will create it
  def self.find_or_create(name:, structure: nil)
    structure = structure.to_sym unless structure.nil?
    structure = nil unless Company.structures.include?(structure)

    create_with(structure: structure).find_or_create_by(name: name)
  end

  #--------------------- Methods ---------------------#

  # Returns the structure as an id number and not a symbol
  def structure_id
    structure_before_type_cast
  end
end
