# Model que representa uma solicitação de preenchimento de formulário.
#
# Um form_request é criado quando um formulário é enviado a um usuário.
# Após o usuário responder, o form_request é removido.
class FormRequest < ApplicationRecord
  self.primary_key = [:user_id, :form_id]
  
  belongs_to :user
  belongs_to :form
end
