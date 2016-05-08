class Background < ApplicationRecord
  has_many :characters, through: :character_backgrounds, inverse_of: :backgrounds
  has_many :character_backgrounds, inverse_of: :background

  validates :name, presence: true

  def display_name
    "#{self.name}"
  end
end
