# Model que representa um usuário do sistema.
#
# Um usuário pode ter múltiplos papéis:
# - Professor (teacher): pode lecionar cursos
# - Aluno (student): pode estar matriculado em cursos
# - Admin (opcional): pode criar templates e formulários
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

  # Verifica se o usuário possui perfil de administrador.
  #
  # Este método não recebe argumentos.
  #
  # Este método retorna um valor booleano: true se o usuário for admin, false caso contrário.
  #
  # Este método não possui efeitos colaterais.
  def admin?
    admin.present?
  end

  has_many :form_requests
  has_many :forms, through: :form_requests
end
