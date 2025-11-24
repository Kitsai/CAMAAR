class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true

  # Teacher relationship
  has_many :taught_courses, class_name: "Course", foreign_key: "teacher_id"

  # Student relationship
  has_many :enrollments, foreign_key: "student_id"
  has_many :courses, through: :enrollments

  # Admin relationship (optional)
  has_one :admin

  def admin?
    admin.present?
  end
end
