# Model que representa um template de formulário.
#
# Templates são criados por admins e contêm um question_set.
# Podem ser reutilizados para criar múltiplos forms.
class Template < ApplicationRecord
  belongs_to :admin
  belongs_to :question_set

  accepts_nested_attributes_for :question_set

  validates :name, presence: true
  validates :question_set, presence: true
  validate :question_set_must_have_questions

  private

  # Valida que o question_set associado possui pelo menos uma questão.
  #
  # Este método não recebe argumentos.
  #
  # Este método não retorna valor; adiciona erros ao model se inválido.
  #
  # Efeitos colaterais: Adiciona mensagens de erro ao objeto se a validação falhar.
  def question_set_must_have_questions
    return unless question_set

    if question_set.data.blank? || question_set.data.empty?
      errors.add(:question_set, "must have at least one question")
    end
  end
end
