class AddTokenToSession < ActiveRecord::Migration[8.0]
  def change
    add_column :sessions, :token, :string
  end
end
