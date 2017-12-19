class CreateAppartments < ActiveRecord::Migration[5.1]
  def change
    create_table :appartments do |t|
      t.string :name
      t.string :address
      t.string :station1
      t.string :station2
      t.string :station3
      t.integer :age
      t.integer :story
      t.integer :floor
      t.decimal :rent, precision: 7, scale: 2
      t.integer :admin_fee
      t.string :initial_cost
      t.string :floor_plan
      t.decimal :surface, precision: 6, scale: 2
      t.integer :pre_monthly_rent
      t.integer :delta_monthly_rent

      t.timestamps
    end
  end
end
