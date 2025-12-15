# Model que representa a matrícula de um aluno em um curso.
#
# Estabelece a relação many-to-many entre User (como student) e Course.
class Enrollment < ApplicationRecord
  belongs_to :student, class_name: "User", foreign_key: "student_id"
  belongs_to :course
end
