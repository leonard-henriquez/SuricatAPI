# Defines a sector,
#   for instance, Banking.
# An opportunity is most likey to be connected to a sector.
class Sector < ApplicationRecord
  # Relations
  belongs_to :sector_category, optional: true
  has_many :opportunities
  has_many :user_opportunities, through: :opportunities

  # Aliases
  alias_attribute :category, :sector_category

  # Validations
  validates :name, presence: true, uniqueness: true

  #--------------------- Class Methods ---------------------#

  # Returns category of this sector
  def self.category
    (to_s + 'Category').constantize
  end

  # Returns a sector matching criteria
  # If it doesn't exist, it will create it
  def self.find_or_create(name:, category: nil)
    item = find_by(name: name)
    return item unless item.nil?

    category = self.category.find_or_create(name: category) unless category.nil?
    create(name: name, category: category)
  end
end
