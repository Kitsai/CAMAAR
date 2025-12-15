# Perfil de administrador vinculado a um User
# Pode criar templates e formulários de avaliação
class Admin < ApplicationRecord
  self.primary_key = "user_id"

  belongs_to :user

  has_many :templates
  has_many :forms
end
