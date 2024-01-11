class CreateBulls < ActiveRecord::Migration[7.1]
  def change
    create_table :bulls do |t|
      t.string :registration_code
      t.string :name
      t.date :born_on
      t.integer :offspring_count

      t.timestamps
    end
  end
end
