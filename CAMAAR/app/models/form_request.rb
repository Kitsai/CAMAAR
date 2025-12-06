class FormRequest < ApplicationRecord
  self.primary_key = [:user_id, :form_id]
  
  belongs_to :user
  belongs_to :form
end
