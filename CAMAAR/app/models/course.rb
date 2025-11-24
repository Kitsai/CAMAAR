class Course < ApplicationRecord
  belongs_to :teacher, class_name: "User", foreign_key: "teacher_id"

  # Student relationship
  has_many :enrollments
  has_many :students, through: :enrollments, source: :student
  has_many :forms
end
