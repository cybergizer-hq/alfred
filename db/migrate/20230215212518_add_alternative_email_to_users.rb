class AddAlternativeEmailToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :alternative_email, :string
  end
end
