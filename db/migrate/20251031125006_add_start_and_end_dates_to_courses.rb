class AddStartAndEndDatesToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :start_date, :date
    add_column :courses, :end_date, :date
  end
end
