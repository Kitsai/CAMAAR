# Classe base abstrata para todos os models do sistema
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
