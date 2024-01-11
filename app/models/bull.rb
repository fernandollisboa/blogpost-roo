class Bull < ApplicationRecord
  validates :registration_code,:name, :born_on, :offspring_count, presence: true
end
