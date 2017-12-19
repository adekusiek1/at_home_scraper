class CreateLinks < ActiveRecord::Migration[5.1]
  def change
    create_table :links do |t|
      t.string :url
      t.integer :appartment_id
      t.integer :quote_company_id

      t.timestamps
    end
  end
end
