class GerenciamentoController < ApplicationController
  def index
    @template = Template.new
  end

end
