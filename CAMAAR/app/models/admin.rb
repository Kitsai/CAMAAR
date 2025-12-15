# Model que representa o perfil de administrador de um usuário.
#
# Este model está associado a um User e fornece capacidades administrativas
# como criar templates e formulários de avaliação.
class Admin < ApplicationRecord
  self.primary_key = "user_id"

  belongs_to :user

  has_many :templates
  has_many :forms
end
