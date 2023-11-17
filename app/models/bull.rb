class Bull < ApplicationRecord
  validates :name, :born_on, :offspring_count, :registration_code, presence: true
end
