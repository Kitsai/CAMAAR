# Solicitação de preenchimento de formulário enviada a um usuário
# Removida após o usuário submeter suas respostas
class FormRequest < ApplicationRecord
  self.primary_key = [:user_id, :form_id]
  
  belongs_to :user
  belongs_to :form
end
