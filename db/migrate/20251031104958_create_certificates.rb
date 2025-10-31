class CreateCertificates < ActiveRecord::Migration[8.0]
  def change
    create_table :certificates do |t|
      t.references :employee, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.string :name
      t.date :issued_on
      t.date :expiry_date
      t.string :issuer
      t.text :notes

      t.timestamps
    end
  end
end
