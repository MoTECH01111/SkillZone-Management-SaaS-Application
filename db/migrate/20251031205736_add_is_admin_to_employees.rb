class AddIsAdminToEmployees < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :is_admin, :boolean
  end
end
