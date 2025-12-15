# Model que representa um conjunto de questões.
#
# As questões são armazenadas em formato JSON (array) no campo data.
# Um question_set pode ser usado por um template e múltiplos forms.
class QuestionSet < ApplicationRecord
  has_one :template
  has_many :forms

  validate :data_must_be_valid_json_array

  private

  # Valida que o campo data contém um array JSON válido e não vazio.
  #
  # Este método não recebe argumentos.
  #
  # Este método não retorna valor; adiciona erros ao model se inválido.
  #
  # Efeitos colaterais: Adiciona mensagens de erro ao objeto se a validação falhar.
  def data_must_be_valid_json_array
    if data.nil?
      errors.add(:data, "can't be blank")
      return
    end

    unless data.is_a?(Array)
      errors.add(:data, "must be a non-empty array of questions")
      return
    end

    if data.empty?
      errors.add(:data, "must be a non-empty array of questions")
    end
  end
end
