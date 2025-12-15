# Matrícula de um aluno em uma turma/curso
# Associa User (como student) a Course
class Enrollment < ApplicationRecord
  belongs_to :student, class_name: "User", foreign_key: "student_id"
  belongs_to :course
end
