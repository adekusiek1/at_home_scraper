class AddIndexToAppartments < ActiveRecord::Migration[5.1]
  def change
    add_index :appartments, :address
  end
end
