class AddAuthorToBooks < ActiveRecord::Migration[8.1]
  def change
    add_reference :books, :author
  end
end
