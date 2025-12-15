# Model que representa uma resposta a um formulário.
#
# As respostas são armazenadas em formato CSV para permitir múltiplas
# respostas em um único campo de texto.
class Answer < ApplicationRecord
  require 'csv'
  
  belongs_to :form

  validates :data, presence: true

  # Faz parsing dos dados de resposta do formato CSV.
  #
  # Este método não recebe argumentos.
  #
  # Este método retorna um array com as respostas individuais.
  #
  # Este método não possui efeitos colaterais.
  def parsed_data
    CSV.parse_line(data) || []
  rescue CSV::MalformedCSVError
    # Fallback para dados legados armazenados com separação simples por vírgula
    data.split(',')
  end

  # Retorna uma resposta específica pelo índice fornecido.
  #
  # Parâmetros:
  #   index: Índice da resposta desejada
  #
  # Este método retorna a resposta na posição especificada, ou nil se o índice for inválido.
  #
  # Este método não possui efeitos colaterais.
  def answer_at(index)
    parsed_data[index]
  end

  # Retorna todas as respostas como um array.
  #
  # Este método não recebe argumentos.
  #
  # Este método retorna um array com todas as respostas.
  #
  # Este método não possui efeitos colaterais.
  def answers
    parsed_data
  end
end
