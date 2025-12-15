# Classe base abstrata para todos os models da aplicação.
#
# Todos os models do sistema herdam desta classe, que por sua vez
# herda de ActiveRecord::Base.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
