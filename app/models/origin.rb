class Origin < ApplicationRecord
  has_many :characters, through: :character_origins, inverse_of: :origins
  has_many :character_origins, inverse_of: :origin

  SOURCES = (Character::RACES|Character::CULTURES|[
    "Template: Clocksmith",
    "Template: Proto"]
  )
  SAMPLE = [
    "Cryogen",
    "Common House of Arcane",
  ]

  validates :source, inclusion: {in: SOURCES }
  validates :name, presence: true

  def display_name
    "#{self.source}|#{self.name}"
  end
end
