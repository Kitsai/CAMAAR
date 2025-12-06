class Answer < ApplicationRecord
  belongs_to :form

  validates :data, presence: true
end
