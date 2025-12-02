class AddNameToTemplates < ActiveRecord::Migration[8.1]
  def change
    add_column :templates, :name, :string
  end
end
