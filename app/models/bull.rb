class Bull < ApplicationRecord
  validates :name, presence: true
  validates :born_on, presence: true
  validates :offspring_count, presence: true
end
