class CreateEnrollments < ActiveRecord::Migration[8.0]
  def change
    create_table :enrollments do |t|
      t.references :employee, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.string :status
      t.date :enrolled_on
      t.date :completed_on
      t.string :grade

      t.timestamps
    end
  end
end
