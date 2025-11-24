class Template < ApplicationRecord
  belongs_to :admin
  belongs_to :question_set
end
