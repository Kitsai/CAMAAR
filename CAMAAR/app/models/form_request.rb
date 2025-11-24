class FormRequest < ApplicationRecord
  belongs_to :user
  belongs_to :form
end
