class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :position
      t.string :department
      t.string :phone
      t.date :hire_date
      t.string :gender

      t.timestamps
    end
    add_index :employees, :email, unique: true
  end
end
