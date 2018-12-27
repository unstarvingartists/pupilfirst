class School < ApplicationRecord
  has_many :courses, dependent: :restrict_with_error
  has_many :school_admins, dependent: :destroy
end