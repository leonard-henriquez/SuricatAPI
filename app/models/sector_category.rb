# Defines categories for sectors.
#   for instance Banking and Insurance could be in a same cateogry: BFA.
class SectorCategory < ApplicationRecord
  # Relations
  has_many :sectors
  has_many :opportunities, through: :sectors

  # Validations
  validates :name, presence: true, uniqueness: true

  #--------------------- Class Methods ---------------------#

  # Returns a sector category matching criteria
  # If it doesn't exist, it will create it
  def self.find_or_create(name:)
    find_or_create_by(name: name)
  end
end
