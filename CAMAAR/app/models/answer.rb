class Answer < ApplicationRecord
  require 'csv'
  
  belongs_to :form

  validates :data, presence: true

  # Faz parsing dos dados de resposta do formato CSV
  def parsed_data
    CSV.parse_line(data) || []
  rescue CSV::MalformedCSVError
    # Fallback para dados legados armazenados com separação simples por vírgula
    data.split(',')
  end

  # Retorna uma resposta específica pelo índice
  def answer_at(index)
    parsed_data[index]
  end

  # Retorna todas as respostas como um array
  def answers
    parsed_data
  end
end
