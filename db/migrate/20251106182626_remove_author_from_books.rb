class RemoveAuthorFromBooks < ActiveRecord::Migration[8.1]
  def change
    remove_column :books, :author, :string
  end
end
