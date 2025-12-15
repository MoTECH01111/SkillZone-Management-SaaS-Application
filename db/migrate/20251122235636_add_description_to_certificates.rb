class AddDescriptionToCertificates < ActiveRecord::Migration[8.0]
  def change
    add_column :certificates, :description, :text
  end
end
