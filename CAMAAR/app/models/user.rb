class User < ApplicationRecord
  has_secure_password validations: false

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, confirmation: true, length: { minimum: 8 }, if: :password_digest_changed?

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

  has_many :form_requests
  has_many :forms, through: :form_requests
end
