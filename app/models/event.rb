# Defines an event, for instance an interview meeting.
class Event < ApplicationRecord
  # Relations
  belongs_to :user

  # Validations
  validates :name, presence: true
end
