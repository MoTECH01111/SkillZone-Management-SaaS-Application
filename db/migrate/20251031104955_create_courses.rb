class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :title
      t.text :description
      t.integer :duration_minutes
      t.string :level
      t.integer :capacity

      t.timestamps
    end
  end
end
