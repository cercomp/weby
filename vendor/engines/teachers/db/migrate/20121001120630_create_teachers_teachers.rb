class CreateTeachersTeachers < ActiveRecord::Migration
  def change
    create_table :teachers_teachers do |t|
      t.string :name
      t.string :email
      t.string :website

      t.timestamps
    end
  end
end
