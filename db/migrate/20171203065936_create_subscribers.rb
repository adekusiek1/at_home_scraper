class CreateSubscribers < ActiveRecord::Migration[5.1]
  def change
    create_table :subscribers do |t|
      t.string :email, unique: true, null: false

      t.timestamps
    end
  end
end
